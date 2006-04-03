require_dependency 'location_filter'

class FindController < ApplicationController
  include Ferret::Search
  
  layout "public"
  helper :show
  helper :band
  helper :portlet
  helper_method :only_local_session_key
  before_filter :check_location_defaults, :except => [:set_location_radius, :toggle_only_local]
  
  # Search
  def band
    return if request.get? and params[:query].nil?
    
    query, radius, lat, long = prepare_query(Band.table_name)
    return if query.nil?
    
    @results, count = Band.ferret_search_date_location(query, nil, lat, long, radius, default_search_options)
    paginate_search_results(count)
  end

  def show
    return if request.get? and params[:query].nil?
    
    query, radius, lat, long = prepare_query(Show.table_name)
    return if query.nil?
    
    @results, count = Show.ferret_search_date_location(query, Time.now, lat, long, radius, default_search_options)
    paginate_search_results(count)
  end
  
  def venue
    return if request.get? and params[:query].nil?
    
    query, radius, lat, long = prepare_query(Venue.table_name)
    return if query.nil?
    
    @results, count = Venue.ferret_search_date_location(query, nil, lat, long, radius, default_search_options)
    paginate_search_results(count)
  end
  
  # Browse
  def browse_popular_bands
    query, radius, lat, long = prepare_query(Band.table_name)
    return if query.nil?
    
    options = default_search_options
    options[:sort] = popularity_sort_field
    
    @results, count = Band.ferret_search_date_location(query, nil, lat, long, radius, options)
    paginate_search_results(count)
    render :action => 'band'

  end
  
  def browse_newest_bands
    query, radius, lat, long = prepare_query(Band.table_name)
    return if query.nil?
    
    options = default_search_options
    options[:sort] = created_on_sort_field
    
    @results, count = Band.ferret_search_date_location(query, nil, lat, long, radius, options)
    paginate_search_results(count)
    render :action => 'band'

  end
  
  def browse_tonights_shows
    query, radius, lat, long = prepare_query(Show.table_name)
    return if query.nil?
    
    options = default_search_options
    options[:exact_date] = true
    
    @results, count = Show.ferret_search_date_location(query, Time.now, lat, long, radius, options)
    paginate_search_results(count)
    render :action => 'show'
  end
  
  def browse_popular_shows
    query, radius, lat, long = prepare_query(Show.table_name)
    return if query.nil?
    
    options = default_search_options
    options[:sort] = popularity_sort_field
    
    @results, count = Show.ferret_search_date_location(query, Time.now, lat, long, radius, options)
    paginate_search_results(count)
    render :action => 'show'
  end
  
  def browse_newest_shows
    query, radius, lat, long = prepare_query(Show.table_name)
    return if query.nil?
    
    options = default_search_options
    options[:sort] = created_on_sort_field
    
    @results, count = Show.ferret_search_date_location(query, Time.now, lat, long, radius, options)
    paginate_search_results(count)
    render :action => 'show'
  end
  
  def browse_popular_venues
    query, radius, lat, long = prepare_query(Venue.table_name)
    return if query.nil?
    
    options = default_search_options
    options[:sort] = popularity_sort_field
    
    @results, count = Venue.ferret_search_date_location(query, nil, lat, long, radius, options)
    paginate_search_results(count)
    render :action => 'venue'
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
  
  # Set some default location params if we are not logged in
  def check_location_defaults
    return if logged_in_fan or @session[:location]
    
    # TODO Could attempt to figure out the users location
    set_location_defaults('', '', 'false', 'false', 'false')
  end
  
  # A bit of a hack, but create the session key to use with the type name
  def only_local_session_key(type)
    "only_local_#{type}".to_sym
  end
  
  def created_on_sort_field
    SortField.new("created_on", {:sort_type => SortField::SortType::INTEGER, :reverse => true})
  end
  
  def popularity_sort_field
    SortField.new("popularity", {:sort_type => SortField::SortType::INTEGER, :reverse => true})
  end
  
  private
  
  def prepare_query(type)
    query = params[:query].nil? ? "" : params[:query].strip
    
    return query, nil, nil, nil if @session[only_local_session_key(type)] == 'false'
    
    radius = @session[:radius]
    if radius != "" and radius.to_f <= 0
      flash[:error] = "The search radius must be a positive number"
      return nil
    end
    
    lat = long = nil
    loc = @session[:location]
    if not loc.nil? and loc != ""
      # FIXME handle exception
      begin 
        zip = Address::parse_city_state_zip(loc.strip)
      rescue Exception => e
        flash[:error] = e.to_s
        return nil
      end
      
      lat = zip.latitude
      long = zip.longitude
    end
    
    return query, radius, lat, long
  end
  
end
