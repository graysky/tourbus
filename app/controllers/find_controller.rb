require_dependency 'searchable'
require_dependency 'geosearch'

class FindController < ApplicationController
  include Geosearch
  include Ical
  include FanLoginSystem
  
  layout "public"
  helper :show
  helper :band
  helper :portlet
  helper :feed
  helper_method :only_local_session_key
  before_filter :check_location_defaults, :except => [:set_location_radius, :toggle_only_local]
  before_filter :fan_login_required, :only => [:fan]
  session :off, :only => [:shows_rss]
  
  # Search
  def band
    query, radius, lat, long = prepare_query(Band.table_name)
    return if query.nil?
    
    # Always search nationally for bands
    radius = lat = long = nil
    
    begin
      @results, count = Band.ferret_search_date_location(query, nil, lat, long, radius, default_search_options)
      paginate_search_results(count)
    rescue Exception => e
      handle_search_exception(e)
      return
    end
  end

  def show
    if params[:radius] and params[:location] and !params[:location].blank?
      # Search came from the front page
      do_set_location_radius
      do_toggle_only_local(true)
    end
    
    options = default_search_options
    options[:include] = [:bands, :venue, :fans]
    options[:sort] = score_sort_field
    
    query, radius, lat, long = prepare_query(Show.table_name)
    return if query.nil?
    
    begin
      @results, count = Show.ferret_search_date_location(query, Time.now, lat, long, radius, options)
      paginate_search_results(count)
    rescue Exception => e
      handle_search_exception(e)
      return
    end
    
    @subscribe_url, @calendar_url = show_subscription_urls(:shows_rss, :shows_ical, :query => query, 
                                           :location => params[:location] || session[:location], 
                                           :radius => radius)
  end
  
  def venue
    query, radius, lat, long = prepare_query(Venue.table_name)
    return if query.nil?
    
    begin
      @results, count = Venue.ferret_search_date_location(query, nil, lat, long, radius, default_search_options)
      paginate_search_results(count)
    rescue Exception => e
      handle_search_exception(e)
      return
    end
  end
  
  def fan  
    query, radius, lat, long = prepare_query(Fan.table_name)
    return if query.nil?
    
    # If we think it's an email address look for an exact match.
    if query.index('@')
      fan = Fan.find_by_contact_email(query)
      if fan
        redirect_to public_fan_url(fan)
        return
      end
    end
    
    begin
      @results, count = Fan.ferret_search_date_location(query, nil, lat, long, radius, default_search_options)
      
      if @results.empty? && !Address.is_zip?(query)
        # Try a fuzzy query so we get partial screennames
        @results, count = Fan.ferret_search_date_location(query + '~', nil, lat, long, radius, default_search_options)
      end
      
      paginate_search_results(count)
    rescue Exception => e
      handle_search_exception(e)
      return
    end
  end
  
  # Browse
  def browse_popular_bands
    query, radius, lat, long = prepare_query(Band.table_name)
    if query.nil?
      render_band
      return
    end
    
    options = default_search_options
    options[:sort] = popularity_sort_field
    
    # Always search nationally for bands
    radius = lat = long = nil
    
    @results, count = Band.ferret_search_date_location(query, nil, lat, long, radius, options)
    paginate_search_results(count)
    render_band

  end
  
  def browse_newest_bands
    query, radius, lat, long = prepare_query(Band.table_name)
    if query.nil?
      render_band
      return
    end
    
    options = default_search_options
    options[:sort] = created_on_sort_field
    
    # Always search nationally for bands
    radius = lat = long = nil
    
    @results, count = Band.ferret_search_date_location(query, nil, lat, long, radius, options)
    paginate_search_results(count)
    render_band
  end
  
  def browse_all_bands
    @supports_prefix_browse = true
    
    conditions = params[:prefix].blank? ? nil : "name like '#{params[:prefix]}%'"
    @pages, @results = paginate(:bands, :order_by => 'name', :per_page => page_size, :conditions => conditions)
    render_band
  end
  
  # Get an RSS feed for a show search or browsing page
  def shows_rss
    query, radius, lat, long = prepare_query(Show.table_name, params[:location], params[:radius], true)
    
    if validate_rss_query(query, radius, lat, long)
      options, title, part = prepare_subscription_query(query, radius, lat, long)
            
      render_shows_rss(part, title) do
        @items, count = Show.ferret_search_date_location(query, Time.now, lat, long, radius, options)
        @items
      end
    end
  end
  
  def shows_ical
    query, radius, lat, long = prepare_query(Show.table_name, params[:location], params[:radius], true)
    
    if validate_ical_query(query, radius, lat, long)
      options, title, part = prepare_subscription_query(query, radius, lat, long)
            
      render_shows_ical(part, title) do
        @items, count = Show.ferret_search_date_location(query, Time.now, lat, long, radius, options)
        @items
      end
    end
  end
  
  def browse_tonights_shows
    query, radius, lat, long = prepare_query(Show.table_name)
    if query.nil?
      render_show
      return
    end
    
    options = default_search_options
    options[:sort] = popularity_sort_field
    options[:exact_date] = true
    options[:include] = :bands
    
    @results, count = Show.ferret_search_date_location(query, Time.now, lat, long, radius, options)
    paginate_search_results(count)
    
    @subscribe_url, @calendar_url = show_subscription_urls(:shows_rss, :shows_ical, :query => "", 
                                               :location => params[:location] || session[:location], 
                                               :radius => radius,
                                               :tonight => true)
                                               
    render_show
  end
  
  def browse_popular_shows
    query, radius, lat, long = prepare_query(Show.table_name)
    if query.nil?
      render_show
      return
    end
    
    options = default_search_options
    options[:sort] = date_sort_field
    options[:conditions] = ['popularity:[1 TO *]']
    
    @results, count = Show.ferret_search_date_location(query, Time.now, lat, long, radius, options)
    paginate_search_results(count)
    
    @subscribe_url, @calendar_url = show_subscription_urls(:shows_rss, :shows_ical, :query => "", 
                                               :location => params[:location] || session[:location], 
                                               :radius => radius,
                                               :popular => true)
    render_show
  end
  
  def browse_upcoming_shows
    query, radius, lat, long = prepare_query(Show.table_name)
    if query.nil?
      render_show
      return
    end
    
    options = default_search_options
    options[:sort] = date_sort_field
    
    @results, count = Show.ferret_search_date_location(query, Time.now, lat, long, radius, options)
    paginate_search_results(count)
    
    @subscribe_url, @calendar_url = show_subscription_urls(:shows_rss, :shows_ical, :query => "", 
                                               :location => params[:location] || session[:location], 
                                               :radius => radius)
    render_show
  end
  
  def browse_popular_venues
    query, radius, lat, long = prepare_query(Venue.table_name)
    if query.nil?
      render_venue
      return
    end
    
    options = default_search_options
    options[:sort] = name_sort_field
    options[:conditions] = [ 'popularity:[1 TO *]']
  
    @results, count = Venue.ferret_search_date_location(query, nil, lat, long, radius, options)
     
    paginate_search_results(count)
    render_venue
  end
  
  def browse_all_venues
    query, radius, lat, long = prepare_query(Venue.table_name)
    if query.nil?
      render_venue
      return
    end
    
    options = default_search_options
    options[:sort] = name_sort_field
  
    @results, count = Venue.ferret_search_date_location(query, nil, lat, long, radius, options)
     
    paginate_search_results(count)
    render_venue
  end
  
  protected
  
  def render_band
    render :action => 'band'
  end
  
  def render_show
    render :action => 'show'
  end
  
  def render_venue
    render :action => 'venue'
  end
  
  def handle_search_exception(e)
    logger.error(e)
    if e.is_a?(Errno::ECONNREFUSED)
      flash.now[:error] = "Sorry, search is currently disabled on the site. Please try again in a few minutes."
    else
      flash.now[:error] = "Sorry, there was an error with your query."
    end
  end
  
  def prepare_subscription_query(query, radius, lat, long)
    title = "shows near " + params[:location]
    options = {}
    # Set a reasonable limit
    options[:num_docs] = 1000
    options[:sort] = reverse_date_sort_field
    
    popular = @params[:popular] == "true"
    if popular
      options[:conditions] = [ 'popularity:[1 TO *]' ]
      title = "popular " + title
    end
    
    tonight = params[:tonight] == "true"
    if tonight
      options[:exact_date] = true
      title = "tonight's " + title
    end
  
    part = MetaFragment.cache_key_part(query, radius, lat, long, popular, tonight)
    
    return options, title, part
  end
  
  def validate_rss_query(query, radius, lat, long)
    if query.nil?
      render_shows_rss("query_error", "ERROR! Invalid query")
      return false
    elsif lat.blank? || long.blank? || radius.blank?
      render_shows_rss("loc error", "ERROR! RSS searches must have a location and radius set")
      return false
    else
      return true
    end
  end
  
  def render_shows_rss(key_part, title, obj = nil)
    
    # Set the right content type
    @headers["Content-Type"] = "application/xml; charset=utf-8"

    key = {:action => 'shows_rss', :part => key_part}

    when_not_cached(key, 240.minutes.from_now) do
      @items = block_given? ? yield : []
    end
    
    # Better URL to use?
    base_url = "http://tourb.us/find/shows"
    
    render(:partial => "shared/rss_feed", :locals => 
      { :obj => obj, :base_url => base_url, :key => key, :items => @items, :title => title })
  end
  
  def validate_ical_query(query, radius, lat, long)
    if query.nil?
      render_shows_ical("query_error", "ERROR! Invalid query")
      return false
    elsif lat.blank? || long.blank? || radius.blank?
      render_shows_ical("loc error", "ERROR! iCal subscriptions must have a location and radius set")
      return false
    else
      return true
    end
  end
  
  def render_shows_ical(key_part, title)
    key = {:action => 'shows_ical', :part => key_part}
    cal_string = ""

    when_not_cached(key, 3.hours.from_now) do
      # Fetch and cache the iCal items
      shows = block_given? ? yield : []
      cal_string = get_ical(shows, title)
      write_fragment(key, cal_string)  
    end
    
    ical_feed = read_fragment(key) || cal_string
    render :text => ical_feed
  end
  
  def page_size
    20
  end
      
end
