require 'cgi'
require_dependency 'emails'
require_dependency 'string_helper'
require_dependency 'metafragment'
require 'net/http'

# The filters added to this controller will be run for all controllers in the application.
# Likewise will all the methods added be available for all controllers.
class ApplicationController < ActionController::Base
  include ActionView::Helpers::TextHelper
  include MetaFragment
  include ExceptionNotifiable
  include Captcha
  
  model :band
  model :fan
  helper :debug
  helper :fan
  helper :portlet
  helper :show
  helper_method :public_url
  helper_method :public_band_url
  helper_method :public_fan_url
  helper_method :public_fan_ical_url
  helper_method :public_fan_webcal_url
  helper_method :public_band_ical_url
  helper_method :public_band_webcal_url
  helper_method :public_venue_ical_url
  helper_method :public_venue_webcal_url
  helper_method :public_show_webcal_url
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
  helper_method :logged_in_as_downtree?
  helper_method :display_404
  helper_method :display_500
  helper_method :public_metro_url
  helper_method :random_catpcha
  helper_method :require_captcha?
  
  before_filter :configure_charsets
  before_filter :login_from_cookie
  before_filter :content

  # Disable password logging
  filter_parameter_logging "password"

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
      
      flash.now[:info] = "#{current.teaser}<br/><a href='/news'>Read more...</a>"
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
        band.save
        return true
      elsif cookies[:type] == 'fan'
        fan = Fan.find_by_uuid(cookies[:login])
        if not fan
          logger.warn("Can't find fan for cookie login: #{cookies['login']}")
          return
        end
        
        session[:fan_id] = fan.id
        fan.last_login = Time.now
        logger.info "Fan #{fan.name} logged in from a cookie"
        
        set_location_defaults(fan.location, fan.default_radius, 'false', 'true', 'true', 'false')
        fan.save
        
        @session[:logged_in_as_downtree] = logged_in_as_downtree?
        return true
      else
        logger.error("Invalid cookie type: #{cookies['type']}")
      end
    end 
  end
  
  # Display the 404 page with same status
  def display_404
    render :file => "#{RAILS_ROOT}/public/404.html", :status => "404 Not Found"
  end

  # Display the 500 page with same status  
  def display_500
    render :file => "#{RAILS_ROOT}/public/500.html", :status => "500 Error"
  end
    
  # Get link to the correct metro
  def public_metro_url(metro)
    url = url_for(:controller => "public", :action => "metro", :metro => metro)
    return url
  end
  
  # Get the public URL for this object or nil
  # if not found
  def public_url(obj)
    return nil if obj.nil?
    
    # Temp hack until fan/band urls contain the host
    url = "http://tourb.us"
    
    url = url + public_fan_url(obj) if obj.kind_of?(Fan)
    url = url + public_band_url(obj) if obj.kind_of?(Band)
    url = public_show_url(obj) if obj.kind_of?(Show)
    url = public_venue_url(obj) if obj.kind_of?(Venue)
    url = public_photo_url(obj, "preview") if obj.kind_of?(Photo)
    return url
  end
  
  # Return the URL of the band, which can be passed
  # as an optional param.
  def public_band_url(band = nil)
    band = @band if band.nil?
    band = logged_in_band if band.nil?
    '/' + band.short_name
  end
  
  def public_fan_url(fan = nil)
    fan = @fan if fan.nil?
    fan = logged_in_fan if fan.nil?
    '/' + 'fan/' + fan.name
  end
  
  # public URL to a show
  def public_show_url(show)
    url_for(:controller => "show", :action => "show", :id => show)
  end
  
  # public URL to a venue 
  def public_venue_url(venue)
    url_for(:controller => "venue", :action => "show", :id => venue)
  end
  
  # Get the URL to the RSS feed for this band
  def public_band_rss_url(band = nil)
    band = @band if band.nil?  
    '/' + band.short_name + "/rss"
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
    '/' + photo.relative_path(version)
  end
  
  # Get the URL to the iCal feed for this fan
  def public_fan_ical_url(fan = nil)
    fan = @fan if fan.nil?  
    url_for(:controller => "fan_public", :action => "ical")
  end
  
  # Get the webcal:// URL to the iCal feed for this fan
  def public_fan_webcal_url(fan = nil)
    fan = @fan if fan.nil?  
    url = url_for(:controller => "fan_public", :action => "ical")
    url.gsub!(/http/, 'webcal')
    return url
  end
  
  # Get the URL to the iCal feed for this band
  def public_band_ical_url(band = nil)
    band = @band if band.nil?  
    '/' + band.short_name + "/ical"
  end
  
  # Get the webcal:// URL to the iCal feed for this band
  def public_band_webcal_url(band = nil)
    band = @band if band.nil?  
    url = '/' + band.short_name + "/ical"
    url.gsub!(/http/, 'webcal')
    return url
  end
  
  # Get the URL to the iCal feed for this venue
  def public_venue_ical_url(venue = nil)
    venue = @venue if venue.nil?  
    url_for(:controller => "venue", :action => "ical", :id => venue.id)
  end
  
  # Get the webcal:// URL to the iCal feed for this venue
  def public_venue_webcal_url(venue = nil)
    venue = @venue if venue.nil?  
    url = url_for(:controller => "venue", :action => "ical", :id => venue.id)
    url.gsub!(/http/, 'webcal')
    return url
  end
  
  # Get the webcal:// URL to the iCal feed for this show
  def public_show_webcal_url(show = nil)
    show = @show if show.nil?  
    url = url_for(:controller => "show", :action => "ical", :id => show.id)
    url.gsub!(/http/, 'webcal')
    return url
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
    [Fan.mike, Fan.gary, Fan.admin, Fan.bushido].include?(logged_in_fan)
  end
  
  # Pick a random captcha and return [key, value] array
  def random_catpcha
    return pick_captcha
  end
  
  # Return true if a captcha check is needed, false if it is not needed
  def require_captcha?
    return !logged_in? && cookies[:tb_cap] != "norobot" 
  end
  
  protected
  
  FAKE_PASSWORD = "******"
  
  # Set the defaults for the user's location for searching and browsing
  def set_location_defaults(loc, radius, only_bands, only_shows, only_venues, only_fans)
    @session[:location] = loc
    @session[:radius] = radius
    @session[:only_local_bands] = only_bands
    @session[:only_local_shows] = only_shows
    @session[:only_local_venues] = only_venues
    @session[:only_local_fans] = only_fans
  end
  
  def show_subscription_urls(rss_action, ical_action, sparams = {})
    if sparams[:radius].blank? || sparams[:location].blank?
      rss = ical = "javascript:alert('You must set a valid location and radius to subscribe to this search')"
    else
      rss = url_for(:action => rss_action) + "?" + subscribe_params(sparams)
      ical = url_for(:action => ical_action).gsub(/http/, 'webcal') + "?" + subscribe_params(sparams)
    end
    
    return rss,ical
  end
  
  def subscribe_params(sparams)
    str = ""
    sparams.each do |key, value|
        str << "&#{key.to_s}=#{CGI::escape(value.to_s)}"
    end
    
    str[1..-1]
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
  
  def paginate_photos
    offset = params[:offset].nil? ? 0 :  params[:offset].to_i
    @photo_count = @photos.size
    if offset > 0
      @photos = @photos[offset..-1]
      @prev_offset = offset - Photo::MAX_PER_PAGE
      @prev_offset = 0 if @prev_offset < 0
    end
    
    if offset + Photo::MAX_PER_PAGE < @photos.size
      @next_offset = offset + Photo::MAX_PER_PAGE
    end
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

  def content
    response.lifetime = 6.hour
    url = "http://www.text-link-ads.com/xml.php?inventory_key=3F6AVIHKZSBZAC7Q8YR9&referer="+CGI::escape(request.env['REQUEST_URI'])
    agent = "&user_agent="+CGI::escape(request.env['HTTP_USER_AGENT'])
    url_time, url_data = fragment_key(url)
  
    #is it time to update the cache?
    time = read_fragment(url_time)
    if (time == nil) || (time.to_time < Time.now)
      @links = requester(url+agent) rescue nil
      #if we can get the latest, then update the cache
      if @links != nil
        expire_fragment(url_time)
        expire_fragment(url_data)
        write_fragment(url_time, Time.now+6.hour)
        write_fragment(url_data, @links)
      else
        #otherwise try again in 1 hour
        write_fragment(url_time, Time.now+1.hour)
        @links = read_fragment(url_data)
      end
    else
      #use the cache
      @links = read_fragment(url_data)
    end
  end
  
  
  def requester(url)
    XmlSimple.xml_in(http_get(url))
  end
  
  
  def http_get(url)
    Net::HTTP.get_response(URI.parse(url)).body.to_s
  end
  
  
  def fragment_key(name)
    return "TLA/TIME/#{name}", "TLA/DATA/#{name}"
  end
  
  private
  
  DEFAULT_PAGE_SIZE = 10
end