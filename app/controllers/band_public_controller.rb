class BandPublicController < ApplicationController
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
      puts "illegal value: " + params[:show_display]
      flash[:error] = "Illegal value for show_display"
    end
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
      begin
        create_new_show_and_venue
      rescue Exception => e
        create_bands_playing_content
        return
      end
      
      # Make sure the current band is in the list of band playing the show
      if @bands_playing.find { |band| band.id == @band.id }.nil?
        @bands_playing << @band
      end
      
      begin
        @bands_playing.each { |band| puts band.name, band.id }
        Band.transaction(*@bands_playing) do
          Show.transaction(@show) do
            @band.save!
            @bands_playing.each do |band| 
              if band.id.nil?
                band.save!
              end
              
              band.play_show(@show, true)
            end
          end
        end
      rescue Exception => ex
        p ex
        create_bands_playing_content
        return
      end
      
      flash[:notice] = 'Show added'
      redirect_to_band_home
    end 
  end
  
  def photo
    render_component :controller => "photo", :action => "show_one", 
                     :params => {"photo_id" => params[:photo_id], "name" => @band.name}
  end
  
  private
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
