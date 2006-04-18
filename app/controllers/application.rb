require 'cgi'
require_dependency 'emails'
require_dependency 'string_helper'
require_dependency 'metafragment'

# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.
class ApplicationController < ActionController::Base
  include ActionView::Helpers::TextHelper
  include MetaFragment
  
  model :band
  model :fan
  helper :debug
  helper :fan
  helper :portlet
  helper :show
  helper_method :public_band_url
  helper_method :public_fan_url
  helper_method :public_fan_ical_url
  helper_method :public_band_ical_url
  helper_method :public_venue_ical_url
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
  helper_method :logged_in_admin
  
  before_filter :configure_charsets
  before_filter :login_from_cookie
  # Check for beta invite cookie in the public controller
  before_filter :beta_cookie, :except => [:beta, :beta_signup, :rss, :ical]

  # Use UTF charsets. From:
  # http://wiki.rubyonrails.org/rails/pages/HowToUseUnicodeStrings
  def configure_charsets
    @headers["Content-Type"] = "text/html; charset=utf-8" 
      suppress(ActiveRecord::StatementInvalid) do
        ActiveRecord::Base.connection.execute 'SET NAMES UTF8'
      end
  end
  
  def announcement
      # Check if there is a current announcement to show
      t = Time.now.to_s(:db)
      current = Announcement.find(:first, :conditions => ["expire_at > ?", t])
      
      return if current.nil?
      
      # TODO Need to check for all / fan / band
      
      # TODO Need to check cookie to let them dismiss it
      
      flash.now[:info] = "#{current.teaser}<br/><a href='/news'>Read more...</a>"
  end
  
  def beta_cookie
    # Secret invite code must match public_controller
    secret = "backstage"
  
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
        
        session[:band_id] = band.id
        band.last_login = Time.now
        logger.info "Band #{band.name} logged in from a cookie"
        
      elsif cookies[:type] == 'fan'
        fan = Fan.find_by_uuid(cookies[:login])
        if not fan
          logger.warn("Can't find fan for cookie login: #{cookies['login']}")
          return
        end
        
        session[:fan_id] = fan.id
        fan.last_login = Time.now
        logger.info "Fan #{fan.name} logged in from a cookie"
        
        @session[:logged_in_as_downtree] = logged_in_as_downtree?
      else
        logger.error("Invalid cookie type: #{cookies['type']}")
      end
    end 
  end
  
  # Increments the objects page count and saves it
  # Assumes that "object.page_views" and "object.save" work
  def inc_page_views(object)

    # Don't count the hit if it came from downtree  
    return if object.nil? or @session[:logged_in_as_downtree]
    # or a profile hit from the fan/band that's it about
    return if logged_in? and object.id == logged_in.id
             
    object.page_views += 1
    object.no_update
    object.save
  end
  
  # Return the URL of the band, which can be passed
  # as an optional param.
  def public_band_url(band = nil)
    band = @band if band.nil?
    band = logged_in_band if band.nil?
    url_for(:controller => '') + band.short_name
  end
  
  def public_fan_url(fan = nil)
    fan = @fan if fan.nil?
    fan = logged_in_fan if fan.nil?
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
    url_for(:controller => "fan_public", :action => "rss")
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
  
  # Get the URL to the iCal feed for this fan
  def public_fan_ical_url(fan = nil)
    fan = @fan if fan.nil?  
    url_for(:controller => "fan_public", :action => "ical")
  end
  
  # Get the URL to the iCal feed for this band
  def public_band_ical_url(band = nil)
    band = @band if band.nil?  
    url_for(:controller => '') + band.short_name + "/ical"
  end
  
    # Get the URL to the iCal feed for this venue
  def public_venue_ical_url(venue = nil)
    venue = @venue if venue.nil?  
    url_for(:controller => "venue", :action => "ical", :id => venue.id)
  end
  
  # Whether there is a band or fan logged in
  def logged_in?
    
    if logged_in_fan or logged_in_band
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
    id = session[:band_id]
    band = nil
    
    # Check cache if the band was already looked up during this request
    if not @cached_band.nil? and @cached_band.id == id
      return @cached_band
    end
      
    if not id.nil?
      
      begin
        band = Band.find(id)
        @cached_band = band # Cache for rest of the request
      rescue ActiveRecord::RecordNotFound
        # In case it was deleted somehow (or during testing)
        logger.error "Could not find cached band with id #{id}"
        flash.now[:error] = "Could not find Band with ID #{id}"
        session[:band_id] = nil # Clear it out
      end
    end
    
    return band
  end
  
  # Check if there is a fan logged in
  def logged_in_fan
    id = session[:fan_id]
    fan = nil
    
    # Check cache if the fan was already looked up during this request
    if not @cached_fan.nil? and @cached_fan.id == id
      return @cached_fan
    end
      
    if not id.nil?
      begin
        fan = Fan.find(id)
        @cached_fan = fan # Cache for rest of the request
      rescue ActiveRecord::RecordNotFound
        # In case it was deleted somehow (or during testing)
        logger.error "Could not find cached Fan with ID #{id}"
        flash.now[:error] = "Could not find Fan with ID #{id}"
        session[:fan_id] = nil # Clear it out
      end
    end
    
    return fan
  end
  
  # Check if there is an admin logged in
  def logged_in_admin
    fan = logged_in_fan
    return nil if fan.nil?
    
    return fan if fan.confirmed? and fan.superuser?
  end
  
  def logged_in_as_downtree?
    [Fan.mike, Fan.gary, Fan.admin].include?(logged_in_fan)
  end
  
  protected
  
  FAKE_PASSWORD = "******"
  
  # Set the defaults for the user's location for searching and browsing
  def set_location_defaults(loc, radius, only_bands, only_shows, only_venues)
    @session[:location] = loc
    @session[:radius] = radius
    @session[:only_local_bands] = only_bands
    @session[:only_local_shows] = only_shows
    @session[:only_local_venues] = only_venues
  end
  
  # Returns a rails paginator
  def paginate_search_results(count)
    @pages = Paginator.new(self, count, page_size, @params['page'])
  end
  
  # Takes into account paging
  def default_search_options
    options = {}
    options[:num_docs] = page_size
    if params['page']
      options[:first_doc] = (params['page'].to_i - 1) * page_size
    end
    
    return options
  end
  
  # Log an error msg and put the message into flash.now
  def error_log_flashnow(msg)
    logger.error(msg)
    flash.now[:error] = msg
  end
  
  def sanitize_text_for_display(text)
    StringHelper::clean_html(text).gsub(/\n/, "<br/>")
  end
  
  def page_size
    return DEFAULT_PAGE_SIZE
  end
  
  private
  
  DEFAULT_PAGE_SIZE = 10
end