module VenueHelper

  def venue_desc_for_editing
    if @venue.description != ""
      "<div id='venue_desc'>#{@venue.description}</div>"
    else
      "<div id='venue_desc'><i>Add a description</i></div>"
    end
  end
  
  def venue_url_for_editing
    if @venue.url != ""
      html = javascript_tag("function launchUrl() { alert('Hello!!'); return true; }")
      html += "<div id='venue_url'><a href='#{@venue.url}' onClick='launchUrl()'>#{@venue.url}</a></div>"
      return html
    else
      "<div id='venue_url'></div>"
    end
  end

end
