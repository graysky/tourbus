require_dependency 'show_creator'

class BandPublicController < ApplicationController
  include ShowCreator
  
  before_filter :find_band
  helper :show
  helper :map
  helper :tag
  helper :comment
  helper :photo
  
  layout "public"
  upload_status_for :change_logo
  
  # The the band homepage
  def index
    # Determine the shows to display
    case params[:show_display]
    when nil, "upcoming"
      @shows = @band.shows.find(:all, :conditions => ["date > ?", Time.now])
    when "recent"
      @shows = @band.shows.find(:all, :conditions => ["date > ? and date < ?", Time.now - 1.week, Time.now])
    when "all"
      @shows = @band.shows
    else
      logger.error "illegal value: " + params[:show_display]
      flash[:error] = "Illegal value for show_display"
    end
    
    # Record the page view
    inc_page_views(@band)
  end
  
  def change_logo
    @band.update_attributes(params[:band])
    @band.save
    
    path = "/" + @band.logo_options[:base_url] + "/" + @band.logo_relative_path
    finish_upload_status "'#{path}'"
  end
  
  def set_bio
    @band.bio = params[:value]
    @band.save
    render :text => @band.bio
  end
  
  def add_show
    if @request.get?
      prepare_new_show
    else
      result = create_edit_show(true)
      return if !result
      
      flash[:notice] = 'Show added'
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
      flash[:notice] = 'Show edited'
      redirect_to_band_home
    end 
  end
  
  def photo
    render_component :controller => "photo", :action => "show_one", 
                     :params => {"photo_id" => params[:photo_id], "name" => @band.name}
  end
  
  private
  
  def create_edit_show(new)
    begin
        create_new_show_and_venue(new)
      rescue Exception => e
        create_bands_playing_content
        return false
      end
      
      # Make sure the current band is in the list of band playing the show
      if @bands_playing.find { |band| band.id == @band.id }.nil?
        @bands_playing << @band
      end
      
      @show.created_by_band = @band
      
      begin
        Band.transaction(*@bands_playing) do
          Show.transaction(@show) do
            @show.bands = @bands_playing
            @show.save!
            
            @bands_playing.each do |band| 
              if band.id.nil?
                band.save!
              end
            end
          end
        end
      rescue Exception => ex
        logger.error(ex.to_s)
        @show.ferret_destroy
        create_bands_playing_content
        return false
      end
  end
  
  def find_band
    
    # See if we are logged in as the band. If not, just use the URL.
    @band = Band.find_by_band_id(params[:band_id])
    
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
