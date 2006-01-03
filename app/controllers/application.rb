require 'cgi'

# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.
class ApplicationController < ActionController::Base
  model :band
  helper :debug
  helper_method :public_band_url
  helper_method :public_fan_url
  helper_method :logged_in?
  helper_method :logged_in_fan
  helper_method :logged_in_band
  helper_method :logged_in
  
  before_filter :configure_charsets

  # Use UTF charsets. From:
  # http://wiki.rubyonrails.org/rails/pages/HowToUseUnicodeStrings
  def configure_charsets
    @headers["Content-Type"] = "text/html; charset=utf-8" 
      suppress(ActiveRecord::StatementInvalid) do
        ActiveRecord::Base.connection.execute 'SET NAMES UTF8'
      end
  end
  
  # Increments the objects page count and saves it
  # Assumes that "object.page_views" and "object.save" work
  def inc_page_views(object)
  
    if object.nil?
      return
    end
  
    # TODO Don't count page views from users G & M
    object.page_views += 1    
    
    # Note: Using this method implies that anything with page views
    # is an item we index. If this is not a good assumption than we
    # can revisit it later.
    object.save_without_indexing
  end
  
  # Return the URL of the band, which can be passed
  # as an optional param.
  def public_band_url(band = nil)
    band = @band if band.nil?
    band = session[:band] if band.nil?
    url_for(:controller => '') + band.band_id
  end
  
  def public_fan_url(fan = nil)
    fan = @fan if fan.nil?
    fan = session[fan] if fan.nil?
    url_for(:controller => '') + 'fan/' + fan.name
  end
  
  # Whether there is a band or fan logged in
  def logged_in?
  
    if logged_in_fan
      return true
    elsif logged_in_band
      return true
    else
      return false
    end
  end
  
  # Return the logged in band or fan
  # or nil if neither are logged in
  def logged_in
  
    if logged_in_fan
      return logged_in_fan
    elsif logged_in_band
      return logged_in_band
    else
      return nil
    end
  end
  
  # There is a band logged in
  def logged_in_band
    session[:band]
  end
  
  # There is a fan logged in
  def logged_in_fan
    session[:fan]
  end
end