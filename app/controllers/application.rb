# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.
class ApplicationController < ActionController::Base
  model :band
  helper :debug
  helper_method :public_band_url
  
  def public_band_url
    url_for(:controller => '') + session[:band].band_id
  end
end