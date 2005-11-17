class VenueController < ApplicationController
  before_filter :find_venue

  layout "public"
  
  def show
  
  end
  
  private
  
  # Find the venue from the ID param
  def find_venue
    # Look up the venue
    v = Venue.find_by_id(params[:id])
    
    #if b == nil or (!session[:band].nil? and session[:band].id == b.id)
    #  b = session[:band]
    #end
    
    @venue = v
  end
  
end
