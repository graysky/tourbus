module VenueHelper

  def venue_desc_for_editing
    if @venue.description != ""
      "<div id='venue_desc'>#{@venue.description}</div>"
    else
      "<div id='venue_desc'>None</div>"
    end
  end

end
