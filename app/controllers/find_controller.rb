class FindController < ApplicationController
  layout "public"
  
  def band
    return if request.get?
    
    query = params[:query].strip
    logger.info "Search for bands: #{query}"
    @results = Band.ferret_search(query)
    logger.info "Found bands: #{@results}"
  end

  def venue
    return if request.get?
  end

  def show
    return if request.get?
    
    query = params[:query].strip
    logger.info "Search for shows: #{query}"
    @results = Show.ferret_search(query)
    logger.info "Found shows: #{@results}"
  end
end
