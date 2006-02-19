require_dependency 'location_filter'

class FindController < ApplicationController
  include Ferret::Search
  
  layout "public"
  helper :show
  helper :portlet
  helper_method :only_local_session_key
  
  def band
    return if request.get? and params[:query].nil?
    
    query, radius, lat, long = prepare_query(Band.table_name)
    
    @results, count = Band.ferret_search(query, default_search_options)
    paginate_search_results(count)
  end

  def show
    return if request.get? and params[:query].nil?
    
    query, radius, lat, long = prepare_query(Show.table_name)
    
    @results, count = Show.ferret_search_date_location(query, Time.now, lat, long, radius, default_search_options)
    paginate_search_results(count)
  end
  
  def venue
    return if request.get? and params[:query].nil?
    
    query, radius, lat, long = prepare_query(Venue.table_name)
    
    @results, count = Venue.ferret_search_date_location(query, nil, lat, long, radius, default_search_options)
    paginate_search_results(count)
  end
  
  # FIXME All browses have to take into account location, and therefore use ferret not the db
  # There are all broken until then
  def browse_popular_bands
    @pages, @results = paginate :bands, :order_by => 'num_fans desc, name asc', :per_page => page_size
    render :action => 'band'
  end
  
  def browse_busiest_bands
    @pages, @results = paginate :bands, :order_by => 'num_fans desc, name asc', :per_page => page_size
    render :action => 'band'
  end
  
  def browse_newest_bands
    @pages, @results = paginate :bands, :order_by => 'created_on desc, name asc', :per_page => page_size
    render :action => 'band'
  end
  
  def browse_tonights_shows
    query, radius, lat, long = prepare_query(Show.table_name)
    
    options = default_search_options
    options[:exact_date] = true
    
    @results, count = Show.ferret_search_date_location(query, Time.now, lat, long, radius, options)
    paginate_search_results(count)
    render :action => 'show'
  end
  
  def browse_popular_shows
    query, radius, lat, long = prepare_query(Show.table_name)
    
    options = default_search_options
    options[:sort] = SortField.new("popularity", {:sort_type => SortField::SortType::INTEGER, :reverse => true})
    
    @results, count = Show.ferret_search_date_location(query, Time.now, lat, long, radius, options)
    paginate_search_results(count)
    render :action => 'show'
  end
  
  def page_size
    20
  end
  
  # To be called via ajax so the session state is always up to date
  def set_location_radius
    @session[:location] = params[:location].strip
    @session[:radius] = params[:radius].strip
  end
  
  def toggle_only_local
    @session[only_local_session_key(params[:type])] = params[:checked]
  end
  
  protected
  
  # A bit of a hack, but create the session key to use with the type name
  def only_local_session_key(type)
    "only_local_#{type}".to_sym
  end
  
  private
  
  def prepare_query(type)
    query = params[:query].nil? ? "" : params[:query].strip
    
    return query, nil, nil, nil if @session[only_local_session_key(type)] == 'false'
    
    # For now, expect a zip code
    # This stuff will be updated
    radius = @session[:radius]
    if radius != "" and radius.to_f <= 0
      flash[:error] = "The search radius must be a positive number"
      # FIXME deal with error
      raise "bad radius"
    end
    
    lat = long = nil
    loc = @session[:location]
    if not loc.nil? and loc != ""
      # FIXME handle exception
      zip = Address::parse_city_state_zip(loc.strip)
      
      lat = zip.latitude
      long = zip.longitude
    end
    
    return query, radius, lat, long
  end
  
end
