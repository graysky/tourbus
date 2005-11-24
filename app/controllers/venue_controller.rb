class VenueController < ApplicationController
  before_filter :find_venue
  helper :show
  helper :map
  helper :show
  helper :tag

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
  
  # Called to auto-complete tag name
  # Assumes param named :tag
  def auto_complete_for_tag
    
    search = params[:tag]
    
    tags = Tag.find(:all,
             :conditions => "name LIKE '#{search}%'",
             :limit => 10)

    # Show the tag hits in a drop down box
    render(
	:partial => "shared/tag_hits", 
	:locals => 
		{
		:tags => tags, 
		}) 
    
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
