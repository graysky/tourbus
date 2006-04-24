require_dependency 'location_filter'
require_dependency 'searchable'

class FindController < ApplicationController
  include Geosearch
  
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
    
    if params[:radius] and params[:location] and !params[:location].blank?
      # Search came from the front page
      do_set_location_radius
      do_toggle_only_local(true)
    end
    
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
  
  def browse_popular_venues
    query, radius, lat, long = prepare_query(Venue.table_name)
    return if query.nil?
    
    options = default_search_options
    options[:sort] = name_sort_field
    options[:conditions] = { 'popularity' => '> 0'}
  
    @results, count = Venue.ferret_search_date_location(query, nil, lat, long, radius, options)
     
    paginate_search_results(count)
    render :action => 'venue'
  end
  
  def page_size
    20
  end
      
end
