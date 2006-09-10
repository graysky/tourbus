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

    # Qualify website URL if needed    
    website = params[:fan][:website]
    if !website.nil? and !website.empty? and website !~ /http/
      # Need to prepend "http://"
      website = "http://" + website
      params[:fan][:website] = website
    end
     
    begin
      @fan.update_attributes(params[:fan])
      
      if params[:lastfm_poll] == "1"
        @fan.fan_services.lastfm_poll = true
      else
        @fan.fan_services.lastfm_poll = false
      end
      
      @fan.fan_services.lastfm_username = params[:lastfm_username]
    
      if @fan.save
        flash.now[:success] = "Settings updated"
      end
    rescue Exception => e
      logger.error "Error saving fan settings (id=#{@fan.id}):#{e.to_s}"
      flash.now[:error] = e.to_s
    end
    
    # We don't want to fail the action if the indexing fails
    @fan.ferret_save
    
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
    # or used the back button (stupid ajax!)
    if !@fan.favorite?(band)
      @fan.add_favorite(band, FavoriteBandEvent::SOURCE_FAN)
      @fan.watch_upcoming([band])
      
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
      render :partial => "shared/remove_favorite_simple", :locals => { :band => band }
    else
      render :partial => "shared/remove_favorite"
    end
  end
  
  
  def remove_favorite_band
    band = Band.find(params[:id])
    if @fan.bands.include?(band)
      @fan.remove_favorite(band, FavoriteBandEvent::SOURCE_FAN)
      
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

  def set_going
    handle_set_going
  end
  
  def set_going_simple
    show = Show.find(params[:id])
    params[:going] = params["going_#{show.id}"]
    handle_set_going
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
    if request.get?
      # Be defensive
      render :nothing => true
      return
    end
    
    username = params[:last_fm_username]
    
    if username == ""
      flash[:error] = "Invalid last.fm username"
      render :action => 'import_favorites'
      return
    end
    
    bands = LastFm.top_50_bands(username)
    
    if bands.nil?
      flash[:error] = "Trouble getting favorite bands for username \"#{username}\". <br>Please check your Last.fm username."
      render :action => 'import_favorites'
      return
    end
    
    if bands.empty?
      flash[:error] = "No bands found for username \"#{username}\""
      render :action => 'import_favorites'
      return
    end
    
    @wishlist, @bands = WishListBand.segment_wishlist_bands(bands)
    
    if params[:lastfm_poll] == "1"
      @fan.fan_services.lastfm_poll = true
      @fan.fan_services.lastfm_username = username
    else
      @fan.fan_services.lastfm_poll = false
    end
    
    @fan.save!
    
    render :action => 'import_favorites_step_2'
  end
  
  def itunes_help
    # Do nothing
  end
  
  def import_itunes
    file = params[:file]
    filename = File.basename(file.original_filename.gsub('\\', '/')).gsub(/[^\w\.\-]/,'_')
      
    begin
      if file.respond_to?(:read)
        raise "The file is larger than 2mb" if file.size > Itunes::MAX_SIZE
        
        bands = Itunes.get_bands_from_playlist(file.read)
        @wishlist, @bands = WishListBand.segment_wishlist_bands(bands)
        
        render :action => 'import_favorites_step_2'
      else
        flash.now[:error] = "Error while loading iTunes file"
        render :action => 'import_favorites'
      end 
    rescue => e
      logger.error(e.to_s)
      
      flash.now[:error] = "Error while loading iTunes file: #{e.to_s}"
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
          @fan.add_favorite(band, FavoriteBandEvent::SOURCE_IMPORT)
          
          # Watch all the band's upcoming shows in the area
          @fan.watch_upcoming([band])
          
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
      render :action => 'import_favorites'
      return
    end
    
    flash[:success] = 'Favorites and Wishlist imported successfully.<br/><br/>Your Shows list below now contains all of the' +
                      ' upcoming shows in your area with your new favorite bands.'
    redirect_to public_fan_url
  end
  
  def wishlist
    @wishlist = @fan.wish_list_bands
  end
  
  def remove_wishlist_band
    @fan.wish_list_bands.delete(WishListBand.find(params[:id]))
    render :text => 'Success'
  end
  
  def send_friend_request
    friend = Fan.find(params[:friend])
    
    if not @fan.outstanding_friend_request?(friend)
      FriendRequest.transaction do
        req = FriendRequest.new(:message => params[:message], :requester => @fan, :requestee => friend)
        req.save!
        
        param = "?req=#{req.uuid}"
        confirm_url = url_for(:action => :confirm_friend_request) + param
        deny_url = url_for(:action => :deny_friend_request) + param
        FanMailer.deliver_friend_request(req, confirm_url, deny_url)
      end
    end
    
    render :nothing => true
  end
  
  def confirm_friend_request
    req = get_friend_request
    return if req.nil?
    
    if req.requestee == @fan
      Fan.transaction do
        req.requestee.add_friend(req.requester)
        req.approved = true
        req.save!
      end
      
      FanMailer.deliver_friend_request_confirmed(req.requester, req.requestee)
      flash[:success] = 'The friendship request was confirmed.'
    else
      flash[:error] = 'That friendship request was not meant for you! Do you have two accounts?'
    end
    
    redirect_to :controller => "fans", :action => :friend_requests
  end
  
  def deny_friend_request
    req = get_friend_request
    return if req.nil?
    
    if req.requestee == @fan
      req.denied = true
      req.save!
      
      FanMailer.deliver_friend_request_denied(req.requester, req.requestee)
      flash[:success] = 'The friendship request was denied.'
    else
      flash[:error] = 'That friendship request was not meant for you! Do you have two accounts?'
    end
    
    redirect_to :controller => "fans", :action => :friend_requests
  end 
  
  def contact_fan
    @other = Fan.find(params[:fan])
    raise "No other specified" unless @other
   
    from_url = public_fan_url(@fan)
    reveal_email = params[:reveal_email] == "true"
    
    FanMailer.deliver_contact_fan(@fan, @other, params[:message], from_url, reveal_email)
    
    render :nothing => true
  end
  
  #########
  # Private
  #########
  private
  
  def get_friend_request
    req = FriendRequest.find_by_uuid(params[:req])
    if req.nil?
      flash.now[:error] = 'Invalid friend request'
      return nil
    end
    
    if req.requestee != @fan and req.requester != @fan
      flash.now[:error] = "Invalid friend request for #{@fan.name}"
      return nil
    end
    
    if req.denied? or req.approved?
      flash.now[:error] = 'This friend request has already been responded to'
      return nil
    end
    
    if @fan.friends_with?(req.requestee)
      flash.now[:error] = 'You are already friends with ' + req.requestee.name
      return nil
    end
    
    return req
  end
  
  def handle_set_going
    @show = Show.find(params[:id])
    
    case params[:going]
      when 'yes'
        @fan.attend_show(@show)
      when 'maybe'
        @fan.watch_show(@show)
      when 'no'
        @fan.stop_attending_show(@show)
        @fan.stop_watching_show(@show)
    end
    
    Fan.transaction(@fan) do
      Show.transaction(@show) do
        # FIXME how do we handle errors here?
        @fan.save!
        @show.save!
      end
    end
    
    @show.ferret_save
    
    @headers["Content-Type"] = "text/javascript"
  end
  
  def find_fan
    fan = logged_in_fan
    fan ||= Fan.new
    @fan = fan
  end
end
