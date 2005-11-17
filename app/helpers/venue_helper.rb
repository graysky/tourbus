module VenueHelper

  # Convert a string to a string formatted to be displayed in a GMarker.
  # They wrap on white space, so it needs to be 
  def gmarker_fmt(str)
    # split on the space 
    out = str.split(' ')
    
    # join with a non-breaking space
    return out.join("&nbsp;")
  end

end
