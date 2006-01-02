class FindController < ApplicationController
  layout "public"
  helper :show
  
  def band
    return if request.get?
    
    query = params[:query].strip
    @results = Band.ferret_search(query)
  end

  def venue
    return if request.get?
  end

  def show
    return if request.get?
    
    query = params[:query].strip
    @results = Show.ferret_search_date_location(query, Time.now, nil, nil, nil)
  end
end
