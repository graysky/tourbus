require_dependency "fan"

module FanLoginSystem
  include LoginSystem
  
  # login_required filter. add 
  #
  #   before_filter :fan_login_required
  #
  # if the controller should be under any rights management. 
  # for finer access control you can overwrite
  #   
  #   def authorize?(user)
  # 
  def fan_login_required
    if @session[:fan] and @session[:fan].confirmed? and authorize?(@session[:fan])
      return true
    end
    
    # store current location so that we can 
    # come back after the user logged in
    store_location
    
    # call overwriteable reaction to unauthorized access
    access_denied
    return false 
  end
  
  def superuser_login_required
    if @session[:fan] and @session[:fan].confirmed? and @session[:fan].superuser?
      return true
    end
    
    # store current location so that we can 
    # come back after the user logged in
    store_location
    
    # call overwriteable reaction to unauthorized access
    access_denied
    return false 
  end

end