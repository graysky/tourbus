module VenueHelper

  def venue_desc
    if @venue.description != ""
      "<div id='venue_desc'>#{h(@venue.description)}</div>"
    else
      "<div id='venue_desc'></div>"
    end
  end
  
  def venue_url
    if @venue.url != ""
      link = @venue.url.sub(/http:\/\//, '') # Shorten link to remove "http://"
      link.sub!(/\/$/, '') # Remove trailing slash
      html = "<div id='venue_url'><a href='#{@venue.url}'>#{link}</a></div>"
    else
      "<div id='venue_url'></div>"
    end
  end

end
