# Helper for publishing RSS feeds.
module FeedHelper

  def feed_title(str)
    "tourb.us | #{str}"
  end
  
  def feed_description(str)
    "tourb.us | #{str}"
  end

  def xml_for_item2(item, base_url)
    # Dispatch to the correct type of helper
    if item.nil?
      # Do nothing
    elsif item.kind_of?(Comment)
      xml_for_comment2(item)
      
    elsif item.kind_of?(Show)
      xml_for_show2(item)
      
    elsif item.kind_of?(Photo)
      xml_for_photo2(item)
    end
  end

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
  def xml_for_show2(show)
    xml = ""
    xml << "<title>Show: #{h(get_show_title(show))}</title>"
    xml << "<pubDate>#{format_time(show.created_on)}</pubDate>"
    
    # TODO Make this cleaner - push into show?
    bands = show.bands.map { |band| band.name }.join(" / ")

    desc = ""    
    desc << "<p><b>Who:</b> #{h(bands)}</p>" 
    desc << "<p><b>When:</b> #{friendly_date(show.date)} at #{friendly_time(show.date)}</p>"
    desc << "<p><b>Where:</b> <a href=\"#{public_venue_url(show.venue)}\">#{h(show.venue.name)}</a></p>"
    desc << "<p><b>Description:</b> #{simple_format( h(sanitize(show.description)) )}</p>"
    desc << "<p><a href=\"#{public_show_url(show)}\">More details...</a></p>"
    
    xml << "<description>#{strip_tags(desc)}</description>"
    return xml
  end
  
  # Format a Comment
  def xml_for_comment2(comment)
    xml = ""
    xml << "<title>Comment from #{h(comment.created_by_name)}</title>"
    xml << "<pubDate>#{format_time(comment.created_on)}</pubDate>"
    xml << "<description>#{strip_tags(simple_format( h(sanitize(comment.body)) ))}</description>"
    return xml
  end
  
  # Format a Photo
  def xml_for_photo2(photo)
    xml = ""
    xml << "<title>Photo from #{photo.created_by_name}</title>"
    xml << "<pubDate>#{format_time(photo.created_on)}</pubDate>"

    s = "<img src=\"" + public_photo_url(photo, "preview") + "\"/>"
    s << "<br/>#{simple_format(h(sanitize(photo.description)))}"

    xml << "<description>#{s}</description>"
    return xml
  end
  
  # Format a Show
  def xml_for_show(xml, show)
     
    title = get_show_title(show)
     
    xml.title("Show: #{title}")
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
  
    xml.title("Comment from #{comment.created_by_name}")
    xml.pubDate( format_time(comment.created_on) )
    xml.description( simple_format( sanitize(comment.body) ) )
  end
  
  # Format a Photo
  def xml_for_photo(xml, photo)

    xml.title("Photo from #{photo.created_by_name}")
    xml.pubDate( format_time(photo.created_on) )

    s = "<img src=\"" + public_photo_url(photo, "preview") + "\"/>"
    
    s << "<br/>#{simple_format(sanitize(photo.description))}"

    xml.description( s )
  end

end