# Handles create/edit/viewing Venues
class VenueController < ApplicationController
  before_filter :find_venue
  helper :show
  helper :map
  helper :tag
  helper :comment
  helper :photo
  helper :feed

  session :off, :only => :rss
  layout "public", :except => [:rss ] 
  
  def add_dialog
    if @request.get?
      @venue = Venue.new
      
      # The initial name might be passed as a parameter
      @venue.name = params[:name]
      render :layout => "minimal"
      return
    end
    
    @venue = Venue.new(params[:venue])
    
    # Construct and verify the full address
    citystatezip = params[:citystatezip]
    addr = @venue.address
    addr += "," if addr != ""
    addr += citystatezip
    
    result = Geocoder.yahoo(addr)
    
    if result && result[:precision] == "address"
      @venue.latitude = result[:latitude]
      @venue.longitude = result[:longitude]
      @venue.city = result[:city]
      @venue.address = result[:address]
      @venue.state = result[:state]
      @venue.zipcode = result[:zipcode]
    elsif not params[:ignore_address_error]
      params[:address_error] = true
      render :layout => "minimal"
      return
    end
    
    if @venue.save
      render :action => :close_dialog, :layout => false
    end
  end
  
  def close_dialog
    
  end
  
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
      flash.now[:error] = "Illegal value for show_display: " + params[:show_display]
    end
    
    # Record the page view
    inc_page_views(@venue)
  end
  
  # TODO FIXME - Can't use "@venue.name" because the venue's ID wans't passed in
  def photo
    render_component :controller => "photo", :action => "show_one", 
                     :params => {"photo_id" => params[:photo_id], "name" => @venue.name}
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

  # RSS feed for the venue
  def rss
    # Set the right content type
    @headers["Content-Type"] = "application/xml; charset=utf-8"

    shows = @venue.shows.find(:all, :conditions => ["date > ?", Time.now])
  
    comments = @venue.comments.find(:all,
                                   :order => "created_on DESC",
                                   :limit => 20
                                   ) 

    photos = @venue.photos.find(:all,
                               :order => "created_on DESC",
                               :limit => 10
                               ) 

    # Items for the feed
    @items = []

    shows.each { |x| @items << x }
    comments.each { |x| @items << x }
    photos.each { |x| @items << x }
    
    # Sort the items by when they were created with the most
    # recent item first in the list
    @items.sort! do |x,y| 
      # Maybe test if x & y respond_to?(created_on)
      # Right now, we just assume it
      y.created_on <=> x.created_on
    end
    
  end
  
  private
  
  # Find the venue from the ID param
  def find_venue
    # Look up the venue
    @venue = Venue.find_by_id(params[:id])
    
  end
  
end
