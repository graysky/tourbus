class VenueController < ApplicationController
  before_filter :find_venue
  helper :show
  
  layout "public"
  
  # For displaying a single venue
  def show
    # Determine the shows to display
    case params[:show_display]
    when nil, "upcoming"
      @shows = @venue.shows.find(:all, :conditions => ["date > ?", Time.now])
    when "recent"
      @shows = @venue.shows.find(:all, :conditions => ["date > ? and date < ?", Time.now - 1.week, Time.now])
    when "all"
      @shows = @venue.shows
    else
      puts "illegal value: " + params[:show_display]
      flash[:error] = "Illegal value for show_display"
    end
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
