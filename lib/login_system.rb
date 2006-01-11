# Base mixin for all login systems
module LoginSystem
  # overwrite this if you want to restrict access to only a few actions
  # or if you want to check if the user has the correct rights  
  # example:
  #
  #  #only allow nonbobs
  #  def authorize?(user)
  #    user.login != "bob"
  #  end
  def authorize?(thing)
    true
  end

  # store current uri in  the session.
  # we can return to this location by calling return_location
  def store_location
    @session['return-to'] = @request.request_uri
  end

  # move to the last store_location call or to the passed default one
  def redirect_back_or_default(default)
    if @session['return-to'].nil?
      redirect_to default
    else
      redirect_to_url @session['return-to']
      @session['return-to'] = nil
    end
  end
  
  # Overwrite if you want to have special behavior in case the user is not authorized
  # to access the current operation. 
  # the default action is to redirect to the login screen
  # example use :
  # a popup window might just close itself for instance
  def access_denied
    redirect_to :controller => "login"
  end
  
end