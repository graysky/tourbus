require_dependency "band"

module BandLoginSystem
  include LoginSystem
  
  # login_required filter. add 
  #
  #   before_filter :band_login_required
  #
  # if the controller should be under any rights management. 
  # for finer access control you can overwrite
  #   
  #   def authorize?(user)
  # 
  def band_login_required
    if @session[:band] and @session[:band].confirmed? and authorize?(@session[:band])
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