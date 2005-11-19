module VenueHelper

  # Convert a string to a string formatted to be displayed in a GMarker.
  # They wrap on white space, so it needs to be 
  def gmarker_fmt(str)
    # split on the space 
    out = str.split(' ')
    
    # join with a non-breaking space
    return out.join("&nbsp;")
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


end
