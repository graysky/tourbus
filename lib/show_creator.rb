require 'uuidtools'

# To be included by controllers that need to add shows
module ShowCreator
  private
  
  def prepare_new_show
    @show = Show.new
    @show.date = Time.now
    @venue = Venue.new
    @bands_playing_content = ""
  end
  
  def create_new_show_and_venue(new)
    if new
      @show = Show.new(params[:show])
    else
      @show.update_attributes(params[:show])
    end
    
    # Get the venue
    begin 
      venue_error = false
      @venue = Venue.find(params[:selected_venue_id])
    rescue
      venue_error = true
    end
      
    if venue_error
      @show.errors.add(nil, "Please select a venue or add a new one")
      @venue = Venue.new(params[:venue])
      raise
    end
  
    @bands_playing = calculate_bands
    @show.venue = @venue
    
    unless params[:ignore_duplicate_show] or not new
      # Look for probable dups
      params[:probable_dupe] = Show.find_probable_dups(@show)
      if params[:probable_dupe]
        raise
      end
    end
  end
  
  def venue_location_conditions()
    if ((@venue.city == "" || @venue.state == "") && @venue.zipcode == "")
      # FIXME
      return ""
      #raise "Please enter a city/state or zipcode"
    end
    
    if (@venue.zipcode != "")
      return "zipcode = '#{@venue.zipcode}'"
    else
      return "city = '#{@venue.city}' and state = '#{@venue.state}'"
    end
  end
  
  def calculate_bands
    bands = []
    short_names = params[:bands_playing].split(":::")
    
    short_names.each do |id|
      band = nil
      if id[0] != "*"
        # It's an id of an existing band
        band = Band.find_by_id(id)
      end
      
      if band.nil?
        band = Band.new
        band.name = CGI.unescape(id[1, id.length])
        band.short_name = Band.name_to_id(band.name)
        band.claimed = false
	band.uuid = UUID.random_create.to_s
        
        logger.warn("FIXME: Add band: #{band.name}, #{band.short_name}")
      else
        logger.debug "Found band for show: #{band.name}"
      end
     
      bands << band
    end
    
    return bands
  end
 
  def create_bands_playing_content(bands = nil)
    bands = calculate_bands if bands.nil?
    @bands_playing_content = render_to_string :partial => "shared/band_playing", 
                                              :collection => bands
    
    # TODO Factor out into method for preparing output                                          
    @bands_playing_content.gsub!(/["']/) { |m| "\\#{m}" }
    @bands_playing_content.strip!
    @bands_playing_content.gsub!(/\n/, "")
    
    if params[:bands_playing].nil? or params[:bands_playing] == ""
      params[:bands_playing] = bands.map {|b| b.id }.join(":::")
    end
  end
end
