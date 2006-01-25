# Helper for publishing RSS feeds.
module FeedHelper

  # Format an individual RSS 2.0 item for an item in the feed
  def xml_for_item(xml, item, base_url)
  
    # Dispatch to the correct type of helper
    if item.nil?
      # Do nothing
    elsif item.kind_of?(Comment)
      xml_for_comment(xml, item)
      
    elsif item.kind_of?(Show)
      xml_for_show(xml, item)
      
    elsif item.kind_of?(Photo)
      xml_for_photo(xml, item)
    end
  
  end

  # Get the title of a show, using the optional title
  # or formatted list of bands.
  def get_show_title(show)
    
    return show.formatted_title
  end

  private
  
  def format_time(time)
    # This is what is used for pubDates
    time.rfc822()
  end
  
  # Format a Show
  def xml_for_show(xml, show)
     
    title = get_show_title(show)
     
    xml.title("New Show: #{title}")
    xml.pubDate( format_time(show.created_on) ) 
    
    desc = ""
    
    bands = show.bands.map { |band| band.name }.join(" / ")
    
    desc << "<p><b>Who:</b> #{bands}" 
    desc << "<p><b>When:</b> #{friendly_date(show.date)} at #{friendly_time(show.date)}"
    desc << "<p><b>Where:</b> <a href=\"#{public_venue_url(show.venue)}\">#{show.venue.name}</a>"
    desc << "<p><b>Description:</b> #{simple_format( sanitize(show.description) )}"
    desc << "<p><a href=\"#{public_show_url(show)}\">More details...</a>"
    
    xml.description( desc )
  end
  
  # Format a Comment
  def xml_for_comment(xml, comment)
  
    xml.title("New Comment from #{comment.created_by_name}")
    xml.pubDate( format_time(comment.created_on) )
    xml.description( simple_format( sanitize(comment.body) ) )
  end
  
  # Format a Photo
  def xml_for_photo(xml, photo)

    xml.title("New Photo from #{photo.created_by_name}")
    xml.pubDate( format_time(photo.created_on) )

    s = "<img src=\"" + public_photo_url(photo, "preview") + "\"/>"
    
    s << "<br/>#{simple_format(sanitize(photo.description))}"

    xml.description( s )
  end

end