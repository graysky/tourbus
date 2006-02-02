# Private controller of fan settings
class FanController < ApplicationController
  include FanLoginSystem
  
  before_filter :fan_login_required
  before_filter :find_fan
  layout "public", :except => [:send_test_sms ] 
  
  def index
  end
  
  def logout
    session[:fan] = nil
    cookies.delete :login
    redirect_to(:controller => "public", :action => "front_page")
  end
  
  def settings
    return if @request.get?
    
    # Reload the fan first, in case changes were made by other procs
    @fan.reload
     
    @fan.update_attributes(params[:fan])
    if @fan.save
      flash[:notice] = "Settings updated"
    else
      # TODO GOTO ERROR
      flash[:notice] = "error"
    end
    
  end
  
  # Send a test SMS message
  def send_test_sms
    # Send the message right away
    RemindersMailer.deliver_sms_test(@fan)
    
    # Return a string
    render :text => "SMS Message Sent"
  end
  
  # Add a new favorite band
  def add_favorite_band
    band = Band.find(params[:id])
    
    # If it's already a favorite then something went wrong, maybe someone just typed in the URL
    return if @fan.has_favorite(band)
    
    @fan.bands << band
    @fan.save!
    
    render :partial => "shared/remove_favorite"
  end
  
  
  def remove_favorite_band
    band = Band.find(params[:id])
    @fan.bands.delete(band)
    @fan.save!
    
    render :partial => "shared/add_favorite"
  end

  # This fan will attend the show
  def add_attending_show
    show = Show.find(params[:id])
    
    # If they are already attending, maybe someone just typed in the URL
    return if @fan.is_attending(show)
    
    @fan.shows << show
    @fan.save!
    
    render :partial => "shared/remove_attending"
  end
  
  # This fan will NOT attend the show
  def remove_attending_show
    show = Show.find(params[:id])
    @fan.shows.delete(show)
    @fan.save!
    
    render :partial => "shared/add_attending"
  end
  
  def change_password
    if request.get?
      @fan.password = @fan.password_confirmation = FAKE_PASSWORD
      return
    end
    
    
    @fan.update_attributes(params[:fan])
    if @fan.password == FAKE_PASSWORD and @fan.password_confirmation == FAKE_PASSWORD
      flash[:error] = "You must enter a new password"
    else
      begin
        @fan.new_password = true
        if @fan.save
          flash[:notice] = "Password changed"
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
    session[:fan] ||= Fan.new
    @fan = session[:fan]
  end
end
