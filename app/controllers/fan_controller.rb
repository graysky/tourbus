require_dependency "mobile_address"

# Private controller of fan settings
class FanController < ApplicationController
  include FanLoginSystem
  
  helper :band
  before_filter :fan_login_required, :except => [:logout]
  before_filter :find_fan
  layout "public", :except => [:send_test_sms ] 
  
  def index
  end
  
  def logout
    session[:fan_id] = nil
    session[:logged_in_as_downtree] = false
    cookies.delete :login
    redirect_to(:controller => "public", :action => "front_page")
  end
  
  def settings
    return if @request.get?
    
    # Reload the fan first, in case changes were made by other procs
    @fan.reload
     
    begin
      @fan.update_attributes(params[:fan])
      if @fan.save
        flash.now[:success] = "Settings updated"
      else
        flash[:error] = "There was an error updating your settings. Please try again."
      end
    rescue Exception => e
      logger.error "Error saving fan settings (id=#{@fan.id}):#{e.to_s}"
      flash[:error] = e.to_s
    end
    
  end
  
  # Send a test SMS message
  def send_test_sms
    # Send the message right away to the address they are testing
    # NOTE: These params are set in the javascript ajax call
    mobile_number = params[:num]
    carrier_type = params[:type]
    
    sms_addr = MobileAddress::get_mobile_email(mobile_number, carrier_type)
    
    if sms_addr.nil? or sms_addr.empty?
      logger.warn "Mobile address was invalid - number: #{mobile_number} carrier: #{carrier_type}"
      resp = "Error sending SMS"
    else
      RemindersMailer.deliver_sms_test(sms_addr)
      resp = "SMS Message Sent"
    end
    
    # Return a string
    render :text => resp
  end
  
  # Add a new favorite band
  def add_favorite_band
    band = Band.find(params[:id])
    
    # If it's already a favorite then something went wrong, maybe someone just typed in the URL
    return if @fan.favorite?(band)
    
    @fan.add_favorite(band)
    
    Fan.transaction(@fan) do
      Band.transaction(band) do
        # FIXME how do we handle errors here?
        @fan.save!
        band.save!
        band.ferret_save
      end
    end
    
    if params[:simple]
      render :partial => "shared/remove_favorite_simple", :locals => { :band => band }
    else
      render :partial => "shared/remove_favorite"
    end
  end
  
  
  def remove_favorite_band
    band = Band.find(params[:id])
    if @fan.bands.include?(band)
      @fan.remove_favorite(band)
      
      Fan.transaction(@fan) do
        Band.transaction(band) do
          # FIXME how do we handle errors here?
          @fan.save!
          band.save!
          band.ferret_save
        end
      end
    end
    
    if params[:simple]
      render :partial => "shared/add_favorite_simple", :locals => { :band => band }
    else
      render :partial => "shared/add_favorite"
    end
  end

  # This fan will attend the show
  def add_attending_show
    show = Show.find(params[:id])
    
    # If they are already attending, maybe someone just typed in the URL
    return if @fan.attending?(show)
    
    @fan.attend_show(show)
    Fan.transaction(@fan) do
      Show.transaction(show) do
        # FIXME how do we handle errors here?
        @fan.save!
        show.save!
        show.ferret_save
      end
    end
    
    render :partial => "shared/remove_attending"
  end
  
  # This fan will NOT attend the show
  def remove_attending_show
    show = Show.find(params[:id])
    @fan.stop_attending_show(show)
    Fan.transaction(@fan) do
      Show.transaction(show) do
        # FIXME how do we handle errors here?
        @fan.save!
        show.save!
        show.ferret_save
      end
    end
    
    render :partial => "shared/add_attending"
  end
  
  # This fan will watch the show
  def add_watching_show
    show = Show.find(params[:id])
    
    # If they are already watching maybe someone just typed in the URL
    return if @fan.watching?(show)
    
    @fan.watch_show(show)
    Fan.transaction(@fan) do
      Show.transaction(show) do
        # FIXME how do we handle errors here?
        @fan.save!
        show.save!
        show.ferret_save
      end
    end
    
    render :partial => "shared/remove_watching"
  end
  
  # This fan will NOT watch the show
  def remove_watching_show
    show = Show.find(params[:id])
    @fan.stop_watching_show(show)
    Fan.transaction(@fan) do
      Show.transaction(show) do
        # FIXME how do we handle errors here?
        @fan.save!
        show.save!
        show.ferret_save
      end
    end
    
    render :partial => "shared/add_watching"
  end
  
  def change_password
    if request.get?
      @fan.password = @fan.password_confirmation = FAKE_PASSWORD
      return
    end
    
    
    @fan.update_attributes(params[:fan])
    if @fan.password == FAKE_PASSWORD and @fan.password_confirmation == FAKE_PASSWORD
      flash.now[:error] = "You must enter a new password"
    else
      begin
        @fan.new_password = true
        if @fan.save
          flash[:success] = "Password changed"
          redirect_to :action => 'settings'
        end
      ensure
        @fan.password = @fan.password_confirmation = ''
      end
    end
  end
  
  def bulk_import
    return if request.get?
    
    names = params[:bulk_names].to_s.gsub(/\r/, '').split(/\n/)
    @wishlist, @bands = WishListBand.segment_wishlist_bands(names)
    
    render :action => 'import_favorites_step_2'
  end
  
  def import_last_fm
    return if request.get?
    
    username = params[:last_fm_username]
    
    if username == ""
      flash[:error] = "Invalid last.fm username"
      render :action => 'import_favorites'
      return
    end
    
    bands = LastFm.top_50_bands(username)
    
    if bands.empty?
      flash[:error] = "No bands found for username \"#{username}\""
      render :action => 'import_favorites'
      return
    end
    
    @wishlist, @bands = WishListBand.segment_wishlist_bands(bands)
    
    render :action => 'import_favorites_step_2'
  end
  
  def import_itunes
    file = params[:file]
    filename = File.basename(file.original_filename.gsub('\\', '/')).gsub(/[^\w\.\-]/,'_')
      
    begin
      if file.respond_to?(:read)
        bands = Itunes.get_bands_from_playlist(file.read)
        @wishlist, @bands = WishListBand.segment_wishlist_bands(bands)
        
        render :action => 'import_favorites_step_2'
      else
        flash[:error] = "Error while loading iTunes file"
        render :action => 'import_favorites'
      end 
    rescue Exception => e
      logger.error(e.to_s)
      
      flash[:error] = "Error while loading iTunes file"
      render :action => 'import_favorites'
    end
    
  end
  
  def import
    return if request.get?
    
    begin
      Fan.transaction(@fan) do
        # Add favorites
        keys = params.keys.grep(/band_/)
        keys.each do |band_key|
          band = Band.find(params[band_key].to_i)
          @fan.add_favorite(band)
          
          # Save but don't reindex the band... we will recalculate popularity overnight
          band.save!
        end
        
        # Add wishlist
        keys = params.keys.grep(/wishlist_/)
        wishlist = keys.collect { |wishlist_key| params[wishlist_key] }
        @fan.add_wish_list_bands(*wishlist)
        
        @fan.save!
      end
    rescue Exception => e
      error_log_flashnow(e.to_s)
      return
    end
    
    flash[:success] = 'Favorites and Wishlist imported successfully'
    redirect_to public_fan_url
  end
  
  def wishlist
    @wishlist = @fan.wish_list_bands
  end
  
  def remove_wishlist_band
    @fan.wish_list_bands.delete(WishListBand.find(params[:id]))
    render :text => 'Success'
  end
  
  #########
  # Private
  #########
  private
  
  def find_fan
    fan = logged_in_fan
    fan ||= Fan.new
    @fan = fan
  end
end
