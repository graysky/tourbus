class FindController < ApplicationController
  layout "public"
  
  def band
    return if request.get?
    
    query = params[:query].strip
    logger.info query
    @results = Band.ferret_search(query)
    logger.info @results
  end

  def venue
    return if request.get?
  end

  def show
    return if request.get?
  end
end
