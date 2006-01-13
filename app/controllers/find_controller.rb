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
      zip = ZipCode.find_by_zip(loc)
      raise "bad zip code" if zip.nil?  
      
      lat = zip.latitude
      long = zip.longitude
    end
    
    @results, count = Show.ferret_search_date_location(query, Time.now, lat, long, radius, default_search_options)
    paginate_search_results(count)
  end
end
