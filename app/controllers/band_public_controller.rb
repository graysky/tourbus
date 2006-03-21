require_dependency 'show_creator'

# Controller for the public page of a band.
class BandPublicController < ApplicationController
  include ShowCreator
  
  session :off, :only => :rss
  before_filter :find_band
  helper :show
  helper :map
  helper :tag
  helper :comment
  helper :photo
  helper :feed
  
  layout "public", :except => [:rss, :add_link ] 
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
    @band.bio = sanitize_text_for_display(params[:value])
    @band.save
    render :text => @band.bio
  end
  
  def add_show
    if @request.get?
      prepare_new_show
    else
      result = create_edit_show(true)
      return if !result
      
      flash[:success] = 'Show added'
      redirect_to_band_home
    end 
  end
  
  def edit_show
    if @request.get?
      @show = Show.find(params[:id])
      create_bands_playing_content(@show.bands)
      params[:selected_venue_name] = @show.venue.name
      params[:selected_venue_id] = @show.venue.id
    else
      create_edit_show(false)
      flash[:success] = 'Show edited'
      redirect_to_band_home
    end 
  end
  
  # Add link to external site
  def add_link
    return if @request.get?

    link = Link.new(params[:link])
    
    @band.links << link
    
    if not @band.save
      flash.now[:error] = "Trouble saving the link"
    end
    
    str = render(:partial => "single_link", :locals => { :link => link })
    
    puts "RENDERED: #{str}"
    
    str
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
      # Maybe test if x & y respond_to?(created_on)
      # Right now, we just assume it
      y.created_on <=> x.created_on
    end
    
  end
  
  private
  
  def create_edit_show(new)
    begin
        create_new_show_and_venue(new)
      rescue Exception => e
        create_bands_playing_content
        params[:error] = e.to_s
        return false
      end
      
      # Make sure the current band is in the list of band playing the show
      if @bands_playing.find { |band| band.id == @band.id }.nil?
        @bands_playing << @band
      end
      
      @show.created_by_band = @band if new
      
      begin
        Band.transaction(*@bands_playing) do
          Show.transaction(@show) do
            @show.bands = @bands_playing
            @show.save!
            
            @bands_playing.each do |band| 
              if band.id.nil?
                band.save!
                band.ferret_save
              end
            end
          end
        end
      rescue Exception => ex
        logger.error(ex.to_s)
        params[:error] = ex.to_s
        create_bands_playing_content
        return false
      end
      
      @show.ferret_save
      return true
  end
  
  def find_band
    
    # See if we are logged in as the band. If not, just use the URL.
    @band = Band.find_by_short_name(params[:short_name])
    
    if @band.nil?
      raise "No such band. Put up an error screen"
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
