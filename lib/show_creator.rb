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
    
    # Get the new or existing venue
    new_venue = false
    if params[:venue_type] == "new"
      new_venue = true
      @venue = Venue.new(params[:venue])
    else
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
    end
  
    # See if we can locate the venue's address
    if new_venue
      if @venue.zipcode == "" and @venue.city == ""
        @venue.errors.add(nil, "Please enter a city, state and zipcode")
        raise
      end
      
      if @venue.zipcode != ""
        addr = "#{@venue.address}, #{@venue.zipcode}"
      else
        addr = "#{@venue.address}, #{@venue.city}, #{@venue.state}"
      end
      
      result = Geocoder.geocode(addr)
      if result && !result["lat"].nil?
        @venue.latitude = result["lat"]
        @venue.longitude = result["long"]
      elsif not params[:ignore_address_error]
        params[:address_error] = true
        raise
      end
    end
    
    @bands_playing = calculate_bands
    @show.venue = @venue
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
    band_ids = params[:bands_playing].split(":::")
    
    band_ids.each do |id|
      band = nil
      if id[0] != "*"
        # It's an id of an existing band
        band = Band.find_by_id(id)
      end
      
      if band.nil?
        band = Band.new
        band.name = CGI.unescape(id[1, id.length])
        band.band_id = Band.name_to_id(band.name)
        band.claimed = false
      else
        logger.debug "Found band for show: #{band.name}"
      end
     
      bands << band
    end
    
    return bands
  end
 
  def create_bands_playing_content(bands = nil)
    bands = calculate_bands if bands.nil?
    puts bands.map {|b| b.name }.join(" and ")
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