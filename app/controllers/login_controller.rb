# Handle logins
class LoginController < ApplicationController
  include LoginSystem

  layout "public"

  # The Login form
  def index
    return if @request.get?
    
    login = params['login']
    passwd = params['password']
    type = params['type']
    
    # Standard error message
    error_msg = "<h2>Login unsuccessful</h2>" +
                "<p>Please check your username and password, " +
                "and that your account has been confirmed.</p>"
    
    if type == "fan"
    
      # Fan login
      if fan = Fan.authenticate(login, passwd)
        
        @session[:fan] = fan
        # Send to their profile page
        redirect_back_or_default( public_fan_url )
      

      else
        # There was an error
        @login_error  = error_msg
      end
    
    elsif type == "band"
    
      # Band login      
      if band = Band.authenticate(login, passwd)

	    # TODO check for unclaimed band
        @session[:band] = band
        # Send to their profile page
        redirect_back_or_default( public_band_url )

      else
        @login_error  = error_msg
      end
      
    end
  end
  
end
