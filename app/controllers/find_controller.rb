require_dependency 'location_filter'

class FindController < ApplicationController
  layout "public"
  helper :show
  
  def band
    return if request.get? and params[:query].nil?
    
    query = params[:query].strip
    @results, count = Band.ferret_search(query, default_search_options)
    paginate_search_results(count)
  end

  def venue
    return if request.get?
  end

  def show
    return if request.get? and params[:query].nil?
    
    query, radius, lat, long = get_location_query_params()
    
    @results, count = Show.ferret_search_date_location(query, Time.now, lat, long, radius, default_search_options)
    paginate_search_results(count)
  end
  
  def venue
    return if request.get? and params[:query].nil?
    
    query, radius, lat, long = get_location_query_params()
    
    @results, count = Venue.ferret_search_date_location(query, nil, lat, long, radius, default_search_options)
    paginate_search_results(count)
  end
  
  private
  
  def get_location_query_params
   query = params[:query].strip
    
    # For now, expect a zip code
    # This stuff will be updated
    radius = params[:radius]
    if radius != "" and radius.to_f <= 0
      flash[:error_message] = "The search radius must be a positive number"
      # FIXME deal with error
      raise "bad radius"
    end
    
    lat = long = nil
    loc = params[:location]
    if not loc.nil? and loc != ""
      # FIXME handle exception
      zip = Address::parse_city_state_zip(loc)
      
      lat = zip.latitude
      long = zip.longitude
    end
    
    return query, radius, lat, long
  end
  
end
