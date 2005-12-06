class VenueController < ApplicationController
  before_filter :find_venue
  helper :show
  helper :map
  helper :tag
  helper :comment

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
  
  # Set the venue description
  def set_description
    @venue.description = params[:value]
    @venue.save
    render :text => @venue.description
  end
  
  # Set the venue url
  def set_url
    @venue.url = params[:value]
    @venue.save
    render :text => @venue.url
  end
  
  private
  
  # Find the venue from the ID param
  def find_venue
    # Look up the venue
    @venue = Venue.find_by_id(params[:id])
    
  end
  
end
