require_dependency "show_creator"

# Handles create/edit/viewing Shows
class ShowController < ApplicationController
  include ShowCreator
    
  helper :map
  helper :tag
  helper :comment
  helper :photo
  helper :feed
  helper :portlet
  
  session :off, :only => :rss
  before_filter :find_show, :except => [ :venue_search ]
  before_filter :some_login_required, :only => [:add]
  layout "public", :except => [:rss ] 
  
  # Show a specific show. (Perhaps this is a bad name for this action?)
  def show
    # Record the page view
    inc_page_views(@show)
  end
  
  def add
    # TODO Among other things error handling
    if @request.get?
      prepare_new_show
    else
      result = create_edit_show(true)
      return if !result
      
      flash[:success] = 'Show added'
      redirect_to_url "/show/#{@show.id}"
    end
  end
  
  def edit
    if @request.get?
      create_bands_playing_content(@show.bands)
      params[:selected_venue_name] = @show.venue.name
      params[:selected_venue_id] = @show.venue.id
    else
      return if not create_edit_show(false)
      flash[:success] = 'Show edited'
      redirect_to_url "/show/#{@show.id}"
    end 
  end
  
  
  # TODO FIXME - Can't use "@show.name" because the show's ID wans't passed in
  def photo
    render_component :controller => "photo", :action => "show_one", 
                     :params => {"photo_id" => params[:photo_id], "name" => @show.name}
  end
  
  # Search for a venue as part of adding a show
  def venue_search
    name = params[:venue_search_term]
    name = params[:name] if name.nil? or name == ""
    name.strip!
    
    if name && name != ""
      @results, count = Venue.ferret_search(name + "*", default_search_options)
    else
      @results = []
    end
    
    paginate_search_results(count)
    
    render(:partial => "shared/venue_results")
  end
  
  # RSS feed for the show
  def rss
    # Set the right content type
    @headers["Content-Type"] = "application/xml; charset=utf-8"

    comments = @show.comments.find(:all,
                                   :order => "created_on DESC",
                                   :limit => 20
                                   ) 

    photos = @show.photos.find(:all,
                               :order => "created_on DESC",
                               :limit => 10
                               ) 

    # Items for the feed
    @items = []

    comments.each { |x| @items << x }
    photos.each { |x| @items << x }
    
    # Add the show itself to the feed
    @items << @show
    
    # Sort the items by when they were created with the most
    # recent item first in the list
    @items.sort! do |x,y| 
      # Maybe test if x & y respond_to?(created_on)
      # Right now, we just assume it
      y.created_on <=> x.created_on
    end
    
  end
  
  def fans
  
  end
  
  private
  
  def create_edit_show(new)
    begin
      create_new_show_and_venue(new)
    rescue Exception => e
      logger.error("Error creating show:\n#{e.backtrace}")
      params[:error] = e.to_s
      create_bands_playing_content
      return false
    end
    
    @show.bands = @bands_playing  
    begin
      Band.transaction(*@bands_playing) do
        Show.transaction(@show) do
          
          if new
            @show.created_by_band = logged_in_band if logged_in_band
            @show.created_by_fan = logged_in_fan if logged_in_fan
          end
          
          # FIXME Clean this stuff up. Temp for debugging
          if !@show.save
            logger.warn(@show.inspect)
            create_bands_playing_content
            return
          end
          
          @bands_playing.each do |band| 
            if band.id.nil?
              if !band.save
                create_bands_playing_content
                return true
              end
            end
            
            band.ferret_save
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
  
  # Find the show from the ID param
  def find_show
    # Look up the show
    @show = Show.find_by_id(params[:id])
  end
  
  def some_login_required
    return true if logged_in_fan
    if logged_in_band
      redirect_to :controller => logged_in_band.short_name, :action => "add_show"
      return false
    end
    
    # Not logged in... TODO handle this better
    redirect_to :controller => ""
    return false
  end
  
end
