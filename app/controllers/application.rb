require 'cgi'
require_dependency 'emails'
require_dependency 'string_helper'

# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.
class ApplicationController < ActionController::Base
  include ActionView::Helpers::TextHelper
  
  model :band
  helper :debug
  helper_method :public_band_url
  helper_method :public_fan_url
  helper_method :public_band_rss_url
  helper_method :public_fan_rss_url
  helper_method :public_show_rss_url
  helper_method :public_venue_rss_url
  helper_method :public_photo_url
  helper_method :public_show_url
  helper_method :public_venue_url
  helper_method :logged_in?
  helper_method :logged_in_fan
  helper_method :logged_in_band
  helper_method :logged_in
  
  before_filter :configure_charsets
  before_filter :login_from_cookie
  # Check for beta invite cookie in the public controller
  before_filter :beta_cookie, :except => :beta

  # Use UTF charsets. From:
  # http://wiki.rubyonrails.org/rails/pages/HowToUseUnicodeStrings
  def configure_charsets
    @headers["Content-Type"] = "text/html; charset=utf-8" 
      suppress(ActiveRecord::StatementInvalid) do
        ActiveRecord::Base.connection.execute 'SET NAMES UTF8'
      end
  end
  
  def beta_cookie
    # TODO Change the secret 
    secret = "3gnm"
  
    # Check for the secret cookie
    unless cookies[:invite] == secret
      redirect_to("/beta")
    end
  end
  
  # See if we can log the user in from a cookie
  def login_from_cookie
    return if not session.is_a?(CGI::Session)
    return if logged_in?
    
    if cookies[:login]
      if cookies[:type] == 'band'
        band = Band.find_by_uuid(cookies[:login])
        if not band
          logger.warn("Can't find band for cookie login: #{cookies['login']}")
          return
        end
        
        session[:band] = band
      elsif cookies[:type] == 'fan'
        fan = Fan.find_by_uuid(cookies[:login])
        if not fan
          logger.warn("Can't find fan for cookie login: #{cookies['login']}")
          return
        end
        
        session[:fan] = fan
      else
        logger.error("Invalid cookie type: #{cookies['type']}")
      end
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
    object.no_update
    object.save
  end
  
  # Return the URL of the band, which can be passed
  # as an optional param.
  def public_band_url(band = nil)
    band = @band if band.nil?
    band = session[:band] if band.nil?
    url_for(:controller => '') + band.short_name
  end
  
  def public_fan_url(fan = nil)
    fan = @fan if fan.nil?
    fan = session[:fan] if fan.nil?
    url_for(:controller => '') + 'fan/' + fan.name
  end
  
  # public URL to a show
  def public_show_url(show)
    url_for(:controller => "show", :action => "show", :id => show.id)
  end
  
  # public URL to a venue 
  def public_venue_url(venue)
    url_for(:controller => "venue", :action => "show", :id => venue.id)
  end
  
  # Get the URL to the RSS feed for this band
  def public_band_rss_url(band = nil)
    band = @band if band.nil?  
    url_for(:controller => '') + band.short_name + "/rss"
  end
  
  # Get the URL to the RSS feed for this fan
  def public_fan_rss_url(fan = nil)
    fan = @fan if fan.nil?  
    url_for(:controller => "fan_public", :action => "rss", :id => fan.id)
  end
  
  # Get the URL to the RSS feed for this show
  def public_show_rss_url(show = nil)
    show = @show if show.nil?  
    url_for(:controller => "show", :action => "rss", :id => show.id)
  end
  
  # Get the URL to the RSS feed for this venue
  def public_venue_rss_url(venue = nil)
    venue = @venue if venue.nil?  
    url_for(:controller => "venue", :action => "rss", :id => venue.id)
  end
  
  # Get the full URL to the photo
  def public_photo_url(photo, version)
    url_for(:controller => '').chop! + photo.relative_path(version)
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
  
  protected
  
  FAKE_PASSWORD = "******"
  
  # Returns a rails paginator
  def paginate_search_results(count)
    @pages = Paginator.new(self, count, PAGE_SIZE, @params['page'])
  end
  
  # Takes into account paging
  def default_search_options
    options = {}
    options[:num_docs] = PAGE_SIZE
    if params['page']
      options[:first_doc] = (params['page'].to_i - 1) * PAGE_SIZE
    end
    
    return options
  end
  
  def sanitize_text_for_display(text)
    StringHelper::clean_html(text).gsub(/\n/, "<br/>")
  end
  
  private
  
  PAGE_SIZE = 10
end