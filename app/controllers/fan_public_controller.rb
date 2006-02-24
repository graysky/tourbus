require_dependency 'favorites_calculator'

# The public page for a Fan
class FanPublicController < ApplicationController
  before_filter :find_fan
  helper :show
  helper :portlet
  helper :band
  helper :map
  helper :tag
  helper :photo
  helper :feed
  #model :favorites_mailer
  upload_status_for :change_logo
  session :off, :only => :rss
  layout "public", :except => [:rss ] 
  
  
  # Show the main fan page
  def index
    
    @shows = @fan.shows.find(:all, :conditions => ["date > ?", Time.now - 2.days], :limit => 7)
    @bands = @fan.bands.find(:all, :limit => 5)
    
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
                                 "showing_creator" => true}
  end
  
  # RSS feed for the fan
  def rss
    # Set the right content type
    @headers["Content-Type"] = "application/xml; charset=utf-8"
    
    # Include upcoming shows they are attending
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
  
  private
  def find_fan
    @fan = Fan.find_by_name(params[:fan_name])
    if @fan.nil?
      raise "No such fan. Put up an error screen"
    end
    
   if logged_in_fan
    @logged_in_as_fan = (logged_in_fan.id == @fan.id)
   end
   
   @fan
  end
end
