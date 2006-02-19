# Handle logins for band and fans
class LoginController < ApplicationController
  include LoginSystem

  layout "public"

  # The Login form
  def index
    if @request.get?
      params[:remember_me] = 'true' if cookies[:login]
      return
    end
    
    login = params['login']
    passwd = params['password']
    type = params['type']
    
    # Standard error message
    error_msg = "Login unsuccessful<br/>" +
                "Please check your username and password, " +
                "and that your account has been confirmed."
    
    if type == "fan"
    
      # Fan login
      if fan = Fan.authenticate(login, passwd)
        
        @session[:fan_id] = fan.id
        
        if params[:remember_me] == 'true'
          cookies[:type] = { :value => 'fan', :expires => Time.now + 5.years }
          cookies[:login] = { :value => fan.uuid, :expires => Time.now + 2.weeks }
        else
          cookies.delete :login
        end
        
        # Set the default location
        if fan.city
          @session[:location] = fan.location
          @session[:radius] = fan.default_radius
        end
        
        # Set up defaults for viewing local stuff
        @session[:only_local_bands] = 'false'
        @session[:only_local_shows] = 'true'
        @session[:only_local_venues] = 'true'
        
        # Send to their profile page
        redirect_back_or_default( public_fan_url )
      
      else
        # There was an error
        flash.now[:error] = error_msg
      end
    
    elsif type == "band"
    
      # Band login      
      if band = Band.authenticate(login, passwd)

	    # TODO check for unclaimed band
        @session[:band_id] = band.id
        
        if params[:remember_me] == 'true'
          cookies[:type] = { :value => 'band', :expires => Time.now + 5.years }
          cookies[:login] = { :value => band.uuid, :expires => Time.now + 2.weeks }
        else
          cookies.delete :login
        end
          
        # Send to their profile page
        redirect_back_or_default( public_band_url )

      else
        flash.now[:error] = error_msg
      end
      
    end
  end
  
  def forgot_password
    if request.get?
      return
    end
    
    email = params['email']
    type = params['type']
    
    # This duplication sucks between fans and bands... should be cleaned up
    # at some point. Would need one mailer...
    if type == "fan"
      fan = Fan.find_by_contact_email(email)
      if fan.nil?
        flash[:error] = "That email address was not found. Did you select the right account type?"
        return
      end
      
      begin
        Fan.transaction(fan) do
          key = fan.generate_security_token
          url = url_for(:action => 'reset_password', :fan_id => fan.id, :key => key)
          FanMailer.deliver_forgot_password(fan, url)
        end
      rescue Exception => e
        flash[:error] = "There was an error trying to reset your password"
        logger.error(e)
        return
      end
    elsif type == "band"
      band = Band.find_by_contact_email(email)
      if band.nil?
        flash[:error] = "That email address was not found. Did you select the right account type?"
        return
      end
      
      begin
        Band.transaction(band) do
          key = band.generate_security_token
          url = url_for(:action => 'reset_password', :band_id => band.id, :key => key)
          BandMailer.deliver_forgot_password(band, url)
        end
      rescue Exception => e
        flash[:error] = "There was an error trying to reset your password"
        logger.error(e)
        return
      end
    end
    
    flash[:success] = "Instructions on how to reset your password were sent to your email address"
    redirect_to :action => ''
  end
 
  def reset_password
    fan_id = params[:fan_id]
    band_id = params[:band_id]
    key = params[:key]
    
    if fan_id
      user = Fan.find(fan_id)
    elsif band_id
      user = Band.find(band_id)
    end
    
    if user.nil?
      flash.now[:error] = "Invalid account id"
      return
    end
    
    if key != user.security_token or user.token_expired?
      flash.now[:error] = "The link you clicked on is invalid or has expired. Please send email to <a href='#{Emails.help}'>#{Emails.help}</a> and explain the situation"
      return
    end
    
    # Create a new password for the user
    @new_password = Fan.generate_password
    user.password = user.password_confirmation = @new_password
    user.new_password = true
    user.security_token = user.token_expiry = nil
    if !user.save
      @new_password = nil
      flash.now[:error] = "We encountered an error while attempting to reset your password."
    end
  end
  
end
