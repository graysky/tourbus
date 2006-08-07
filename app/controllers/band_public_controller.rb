require_dependency 'show_creator'
require_dependency 'ical'
require_dependency 'badge'


# Controller for the public page of a band.
class BandPublicController < ApplicationController
  include ShowCreator
  include Ical
  include Badge
  
  session :off, :only => [:rss, :ical, :external_map]
  before_filter :find_band, :except => :no_such_band
  helper :show
  helper :map
  helper :tag
  helper :comment
  helper :photo
  helper :feed
  helper :portlet
  
  layout "public", :except => [:rss, :ical, :add_link, :edit_link, :delete_link ] 
  upload_status_for :change_logo
  
  # The the band homepage
  def index
    @shows = @band.shows.find(:all, :conditions => ["date > ?", Time.now - 2.days], :limit => 7)
    
    # Record the page view
    inc_page_views(@band)
  end
  
  def shows
    @shows = @band.shows.find(:all, :conditions => ["date > ?", Time.now - 2.days])
  end
  
  def all_shows
    @shows = @band.shows.find(:all)
  end
  
  def fans
  
  end
  
  
  def enable_editing
    @headers["Content-Type"] = "text/javascript"
  end
  
  def disable_editing
    @headers["Content-Type"] = "text/javascript"
  end
  
  def change_logo
    begin
      @band.update_attributes(params[:band])
      @band.save
      
      path = "/" + @band.logo_options[:base_url] + "/" + @band.logo_relative_path
      finish_upload_status "'#{path}'"
    rescue Exception  => e
      logger.error(e.to_s)
    end
  end
  
  def set_bio
    if logged_in? && params[:value]
      @band.bio = sanitize_text_for_display(params[:value])
      @band.save
    end
    render :text => @band.bio || ''
  end
    
  # Add link to external site
  def add_link
    return if @request.get?

    link = Link.new(params[:link])
    link.data = link.clean_url(link.data)
    @band.links << link
    
    if not @band.save
      error_log_flashnow("Trouble saving the link")
    end
    
    render(:partial => "list_links", :locals => { :links => @band.links, :can_edit => true })
  end
  
  # Edit link to external site
  def edit_link
    return if @request.get?

    id = params[:link][:id]

    name = params[:link][id][:name]
    url = params[:link][id][:data]

    link = Link.find(id)

    link.name = name
    link.data = link.clean_url(url)
    
    if not link.save
      error_log_flashnow("Trouble saving the link")
    end
    
    render(:partial => "list_links", :locals => { :links => @band.links, :can_edit => true })
  end
  
  # Delete link to external site
  def delete_link
    return if @request.get?
  
    id = params[:link][:id]
    Link.find(id).destroy
    
    render(:partial => "list_links", :locals => { :links => @band.links, :can_edit => true })
  end
  
  def photo
    render_component :controller => "photo", :action => "show_one", 
                     :params => {"photo_id" => params[:photo_id], "name" => @band.name}
  end
  
  def external_map
    @shows = @band.shows.find(:all, :conditions => ["date > ?", Time.now])
    render :layout => "iframe"
  end
  
  # RSS feed for the band
  def rss
    # Set the right content type
    @headers["Content-Type"] = "application/xml; charset=utf-8"

    # Check how they want it sorted
    sort_by = params['sort'] || :added

    key = {:action => 'rss', :part => "band_feed_#{sort_by.to_s}"}

    when_not_cached(key, 120.minutes.from_now) do
      # Fetch and cache the RSS items
      get_rss_items(sort_by.to_sym)
    end
    
    # The external URL to this band
    base_url = public_band_url(@band)
    
    render(:partial => "shared/rss_feed", :locals => 
      { :obj => @band, :base_url => base_url, :key => key, :items => @items, :title => "#{@band.name}" })
  end
  
  def ical
    key = {:action => 'ical', :part => 'band_feed'}
    cal_string = ""
    
    when_not_cached(key, 4.hours.from_now) do
      # Fetch and cache the iCal items
      get_ical_items
      cal_string = get_ical(@shows, @band.name)
      write_fragment(key, cal_string)  
    end
    
    ical_feed = read_fragment(key) || cal_string    
    render :text => ical_feed
  end
  
  # Javascript for badge
  def js
    # Get the contents for the badge
    badge = get_html_badge(@band, params)
            
    render :text => badge
  end
  
  private

  def get_ical_items
    # Include all upcoming shows 
    @shows = @band.shows.find(:all, :conditions => ["date > ?", Time.now])
  end

  # Make queries to get the items for RSS feed
  # sort_by => :added (default: when show was added)
  #            :show (order by show dates)
  def get_rss_items(sort_by)
    # Default, sort by the date the show was added  
    sort_by_date_added = true
    
    # Optionally sort by show date
    sort_by_date_added = false if sort_by == :show
  
    # Make the DB queries to get the items for RSS feed
    shows = @band.shows.find(:all, :conditions => ["date > ?", Time.now])
    
    comments = @band.comments.find(:all,
                                   :order => "created_on DESC",
                                   :limit => 10
                                   ) 

    photos = @band.photos.find(:all,
                               :order => "created_on DESC",
                               :limit => 10
                               ) 

    # Items for the feed
    @items = shows + comments + photos

    # Sort the items by when they were created with the most
    # recent item first in the list
    @items.sort! do |x,y| 
      # Sort the items using either date added or show date
      if sort_by_date_added
        y.created_on <=> x.created_on
      else
        x.date <=> y.date
      end
    end
  end
  
  def no_such_band
  end
  
  private

  def find_band
    # See if we are logged in as the band. If not, just use the URL.
    @band = Band.find_by_short_name(params[:short_name])
    
    if @band.nil?
      # Could not find the band
      render :action => 'no_such_band', :status => "404 Not Found"
      return false
    end
    
   if logged_in_band
    @logged_in_as_band = (logged_in_band.id == @band.id)
   end
   
   @band
  end
  
  def redirect_to_band_home(action = nil)
    url = public_band_url + (action.nil? ? "" : "/" + action)
    redirect_to url
  end
end
