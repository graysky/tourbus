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
    cookies.delete :login
    redirect_to(:controller => "public", :action => "front_page")
  end
  
  def settings
    return if @request.get?
    
    # Reload the fan first, in case changes were made by other procs
    @fan.reload
     
    @fan.update_attributes(params[:fan])
    if @fan.save
      flash.now[:success] = "Settings updated"
    else
      # TODO GOTO ERROR
      flash[:notice] = "error"
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
    
    @fan.bands << band
    band.num_fans += 1
    
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
      @fan.bands.delete(band)
      band.num_fans -= 1
      
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
