require_dependency 'favorites_calculator'

# The public page for a Fan
class FanPublicController < ApplicationController
  before_filter :find_fan, :except => :no_such_fan
  helper :show
  helper :portlet
  helper :band
  helper :map
  helper :tag
  helper :photo
  helper :feed
  helper :comment
  upload_status_for :change_logo
  session :off, :only => [:rss, :ical, :webcal ]
  layout "public", :except => [:rss, :ical, :webcal ] 
  
  # Show the main fan page
  def index
    
    @shows = @fan.shows.find(:all, :conditions => ["date > ?", Time.now - 2.days], :limit => 7)
    @bands = @fan.bands.random(5)
    
    if @logged_in_as_fan and @session[:first_login] and @fan.last_login > 8.hours.ago
      flash.now[:info] = render_to_string :action => 'intro_msg', :layout => false
    end
    
    # Record the page view
    inc_page_views(@fan)
  end
  
  def shows
    @shows = @fan.shows.find(:all, :conditions => ["date > ?", Time.now - 2.days])
  end
  
  def all_shows
    @shows = @fan.shows.find(:all)
  end
  
  def favorite_bands
    @bands = @fan.bands.find(:all)
  end
  
  def change_logo
    @fan.update_attributes(params[:fan])
    @fan.save
    
    path = "/" + @fan.logo_options[:base_url] + "/" + @fan.logo_relative_path
    finish_upload_status "'#{path}'"
  end
  
  # do we really need a real name?
  def set_real_name
    @fan.real_name = params[:value]
    @fan.save
    render :text => @fan.bio
  end
  
  def set_bio
    @fan.bio = sanitize_text_for_display(params[:value])
    @fan.save
    render :text => @fan.bio
  end
  
  
  def photo
    render_component :controller => "photo", :action => "show_one", 
                     :params => {"photo_id" => params[:photo_id], 
                                 "name" => @fan.name, 
                                 "showing_creator" => false}
  end
  
  # RSS feed for the fan
  def rss
    # Set the right content type
    @headers["Content-Type"] = "application/xml; charset=utf-8"
    
    key = {:action => 'rss', :part => 'fan_feed'}

    when_not_cached(key, 30.minutes.from_now) do
      # Fetch and cache the RSS items
      get_rss_items
    end
    
    # The external URL to this fan
    base_url = public_fan_url(@fan)
    
    render(:partial => "shared/rss_feed", 
      :locals => { :obj => @fan, :base_url => base_url, :key => key, :items => @items })
  end
  
  # An iCal feed
  # http://en.wikipedia.org/wiki/RFC2445_Syntax_Reference
  # http://en.wikipedia.org/wiki/ICalendar
  def ical
    # Set the right content type
    @headers["Content-Type"] = "text/calendar;"
    
    key = {:action => 'ical', :part => 'fan_feed'}

    #when_not_cached(key, 30.minutes.from_now) do
      # Fetch and cache the iCal items
      get_ical_items
    #end
    
    render(:partial => "shared/ical_feed", 
      :locals => { :shows => @shows, :key => key })
  end
  
  def webcal
    # Set the right content type
    @headers["Content-Type"] = "text/calendar;"
    
    key = {:action => 'ical', :part => 'fan_feed'}

    #when_not_cached(key, 30.minutes.from_now) do
      # Fetch and cache the iCal items
      get_ical_items
    #end
    
    render(:partial => "shared/ical_feed", 
      :locals => { :shows => @shows, :key => key })
  end
  
  private
  
  # Make queries to get the items for iCal feed
  def get_ical_items
    # Include upcoming shows they are attending and watching
    @shows = @fan.shows.find(:all, :conditions => ["date > ?", Time.now])
  end
  
  # Make queries to get the items for RSS feed
  def get_rss_items
    # Include upcoming shows they are attending and watching
    shows = @fan.shows.find(:all, :conditions => ["date > ?", Time.now])
    
    # Include favories that have 
    updated_since = Time.now - 2.weeks
    
    faves = FavoritesCalculator.new(@fan, updated_since)
    
    new_fave_shows = faves.new_shows
    
    # Items for the feed and remove dups
    @items = shows | new_fave_shows

    # Sort the items by when they were created with the most
    # recent item first in the list
    @items.sort! do |x,y| 
      # Maybe test if x & y respond_to?(created_on)
      # Right now, we just assume it
      y.created_on <=> x.created_on
    end
  end
  
  def no_such_fan
  end
  
  private
  
  def find_fan
    @fan = Fan.find_by_name(params[:fan_name])
    if @fan.nil?
      render :action => 'no_such_fan', :status => "404 Not Found"
      return false
    end
    
   if logged_in_fan
    @logged_in_as_fan = (logged_in_fan.id == @fan.id)
   end
   
   @fan
  end
end
