module MapHelper
  def gmaps_header
    out = "<script src='http://maps.google.com/maps?file=api&v=1&key=#{google_api_key}' type='text/javascript'></script>"
    out << "<script src='/javascripts/map.js' type='text/javascript'></script>"
  end
  
  # Convert a string to a string formatted to be displayed in a GMarker.
  # They wrap on white space, so it needs to use nbsp's.
  def gmarker_fmt(str)
    # split on the space 
    out = str.split(' ')
    
    # join with a non-breaking space
    s = out.join("&nbsp;")
    
    # Convert single and double quotes, borrowed from escape_javascript
    s.gsub!(/["']/) { |m| "\\#{m}" }

    return s
  end
  
  # Return HTML to provide a link to Google Maps
  def google_map_link(venue)

    if (venue == nil)
      return ""
    end
    
    # Form the pieces that will go in the url
    venue_str = venue.address + " " + venue.city + " " + venue.state + " " + venue.zipcode
    
    # Encode the URL, converting + symbols for spaces
    url = "http://maps.google.com/maps?q=" + venue_str.split(' ').join('+')
    
    href = "<a href=\"#{url}\" target=\"_blank\">"
    
    out = href + "Full map and directions" + "</a>&nbsp;"
    
    out += href + "<img border=0 src=\"/images/bt-newwin.gif\"></a>"
    
    return out
  end
  
  def center_and_zoom_to_shows(shows)
    
    if shows.nil? or shows.empty?
      # Center on the US
      return "map.centerAndZoom(new GPoint(-96.809567, 39.696987), 14);"
    end
    
    # Calculate the min and max longitude/latitude
    min_long = shows.min {|a,b| a.venue.longitude.to_f <=> b.venue.longitude.to_f }.venue.longitude.to_f
    max_long = shows.max {|a,b| a.venue.longitude.to_f <=> b.venue.longitude.to_f }.venue.longitude.to_f
    min_lat = shows.min {|a,b| a.venue.latitude.to_f <=> b.venue.latitude.to_f }.venue.latitude.to_f
    max_lat = shows.max {|a,b| a.venue.latitude.to_f <=> b.venue.latitude.to_f }.venue.latitude.to_f
    
    # Calculate the center point and deltas
    center_long = (min_long + max_long) / 2
    center_lat = (min_lat + max_lat) / 2
    delta_long = max_long - min_long
    delta_lat = max_lat - min_lat
    
    # Write the javascript to center and zoom at the correct level, assuming
    # a GMap variable "map" in scope
    js =  "var center = new GPoint(#{center_long}, #{center_lat});"
    js << "var delta = new GSize(#{delta_long}, #{delta_lat});"
    js << "var min_zoom = map.spec.getLowestZoomLevel(center, delta, map.viewSize);"
    js << "map.centerAndZoom(center, min_zoom);"
  end
  
  private
  
  def google_api_key
    GOOGLE_API_KEYS[request.host]
  end
  
  GOOGLE_API_KEYS =
  {
    'beta.tourb.us' => 'ABQIAAAAY1hCFaQKc0xQEXTL--ZLyRS5ZthBrIv-T9DBi55MMglpzbCE5xRzIO8d_LpTRN0egaYA2pYC9jLO2g',
    'localhost' => 'ABQIAAAAY1hCFaQKc0xQEXTL--ZLyRTJQa0g3IQ9GZqIMmInSLzwtGDKaBQvnyvA_KrOjoT8VFjieesV3JrWDg',
    'tourb.us' => 'ABQIAAAAY1hCFaQKc0xQEXTL--ZLyRQvbXqN3lu3jZhXwMK1jWlmj5z07xR6MqgQAuu9XJHLylfPKmBxOF70Aw'  
  } unless const_defined?('GOOGLE_API_KEYS')
  
end