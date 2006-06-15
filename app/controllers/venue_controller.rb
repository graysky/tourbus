require_dependency 'ical'

# Handles create/edit/viewing Venues
class VenueController < ApplicationController
  include Ical
  before_filter :find_venue, :except => :add_dialog
  helper :show
  helper :map
  helper :tag
  helper :comment
  helper :photo
  helper :feed
  helper :portlet

  session :off, :only => [:rss, :ical]
  layout "public", :except => [:rss, :ical ] 
  
  def add_dialog
    if @request.get?
      @venue = Venue.new
      
      # The initial name might be passed as a parameter
      @venue.name = params[:name]
      render :layout => "minimal"
      return
    end
    
    @venue = Venue.new(params[:venue])
    @venue.short_name = Venue.name_to_short_name(@venue.name)
    result = Geocoder.yahoo(@venue.address_one_line)
    
    if result && result[:precision] == "address"
      @venue.set_location_from_hash(result)
    elsif not params[:ignore_address_error]
      params[:address_error] = true
      render :layout => "minimal"
      return
    end
    
    if @venue.save
      @venue.ferret_save
      render :action => :close_dialog, :layout => false
    end
  end
  
  def close_dialog
    
  end
  
  # For displaying a single venue
  def show
    # Determine the shows to display
    @shows = @venue.shows.find(:all, :conditions => ["date > ?", Time.now - 2.days], :limit => 7)
    
    # Record the page view
    inc_page_views(@venue)
  end
  
  def shows
    @shows = @venue.shows.find(:all, :conditions => ["date > ?", Time.now - 2.days])
  end
  
  def all_shows
    @shows = @venue.shows.find(:all)
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

    key = {:action => 'rss', :part => 'venue_feed'}

    when_not_cached(key, 120.minutes.from_now) do
      # Fetch and cache the RSS items
      get_rss_items
    end

    # The external URL to this venue
    base_url = public_venue_url(@venue)
    
    render(:partial => "shared/rss_feed", 
      :locals => { :obj => @venue, :base_url => base_url, :key => key, :items => @items, :title => "#{@venue.name}"  })
  end
  
  # iCal feed for this venue
  def ical
    key = {:action => 'ical', :part => 'venue_feed'}
    cal_string = ""
    
    when_not_cached(key, 4.hours.from_now) do
      # Fetch and cache the iCal items
      get_ical_items
      cal_string = get_ical(@shows, @venue.name)
      write_fragment(key, cal_string)  
    end
    
    ical_feed = read_fragment(key) || cal_string
    render :text => ical_feed
  end
  
  private
  
  def get_ical_items
    # Include all upcoming shows 
    @shows = @venue.shows.find(:all, :conditions => ["date > ?", Time.now])
  end
  
  # Make queries to get the items for RSS feed
  def get_rss_items
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
  
  def no_such_venue
  end
  
  # Find the venue from the ID param
  def find_venue
    # Look up the venue
    @venue = Venue.find_by_id(params[:id])
    
    if @venue.nil?
      # Could not find the venue
      render :action => 'no_such_venue', :status => "404 Not Found"
      return false
    end
  end
  
end
