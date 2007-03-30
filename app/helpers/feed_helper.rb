# Helper for publishing RSS and iCalendar feeds.
module FeedHelper

  def feed_title(str)
    "tourb.us | #{str}"
  end
  
  def feed_description(str)
    "tourb.us generated feed for #{str}"
  end

  # Parameters:
  # obj - The primary object of the feed
  # item - A single item for the feed
  # base_url - The base url of the site
  def xml_for_item(obj, item, base_url)
    # Dispatch to the correct type of helper
    if item.nil?
      # Do nothing
    elsif item.kind_of?(Show)
      xml_for_show(obj, item)
    elsif item.kind_of?(Comment)
      xml_for_comment(item)
    elsif item.kind_of?(Photo)
      xml_for_photo(item)
    end
  end

  # Get the title of a show, using the optional title
  # or formatted list of bands.
  def get_show_title(show)
    return show.formatted_title
  end

  protected
  
  # Format text according to iCal rules
  # http://en.wikipedia.org/wiki/RFC2445_Syntax_Reference#Text
  def ical_format_text(text)
    # Note that the order of rules is important
    text.gsub!(/"/, 'DQUOTE')
    text.gsub!(/:/, '":"')
    text.gsub!(/\\/, '\\\\\\\\') # Convert \ => \\
    text.gsub!(/,/, '\,') 
    text.gsub!(/;/, '\;') 
    text.gsub!(/(\r\n|\n|\r)/, "\\n")
    text.gsub!(/\\n\\n+/, "\\n") # zap dupes
    text
  end
  
  # Format an address for a venue
  def ical_address(venue)
    s = ""
    s << venue.name + ", "
    s << venue.address + ", "
    s << venue.city + ", " + venue.state
    
    ical_format_text(s)
  end
  
  # Return a string that corresponds to a valid iCal Date-time
  # http://en.wikipedia.org/wiki/RFC2445_Syntax_Reference#Date-time
  def ical_format_time(time)
    # Format 1 (local time) YYYYMMDDTHHMMSS
    # Format 2 (UTC time) YYYYMMDDTHHMMSSZ
    
    # We store dates in local time, so using format 1
    time.strftime("%Y%m%dT%H%M%S")
  end
  
  def rss_format_time(time)
    # This is what is used for pubDates
    time.rfc822()
  end
  
  # Get the URL for the item with tracking code
  def item_url(item)
    return "#{public_url(item)}?utm_source=rss&utm_medium=feed"
  end
  
  # Format a Show
  def xml_for_show(obj, show)
  
    # For fans, we show info on their friends
    fan = nil
    fan = obj if obj.kind_of?(Fan)
      
    xml = ""
    xml << "<title>Show: #{h(get_show_title(show))}</title>"
    xml << "<link>#{item_url(show)}</link>"
    xml << "<pubDate>#{rss_format_time(show.created_on)}</pubDate>"
    
    bands = show.bands.map { |band| 
      "<a href=\""+ item_url(band)+ "\">"+h(band.name)+"</a>"
    }.join(" / ")

    desc = ""    
    desc << "<p><b>Who:</b> #{bands}</p>" 
    desc << "<p><b>When:</b> #{friendly_date(show.date)} at #{friendly_time(show.date)}</p>"
    desc << "<p><b>Where:</b> <a href=\"#{item_url(show.venue)}\">#{h(show.venue.name)}</a></p>"
    
    if !show.description.empty?
      desc << "<p><b>Description:</b> #{simple_format( h(sanitize(show.description)) )}</p>"
    end
    
    # Add the list of their friends attending
    if !fan.nil? and fan.friends.size > 0
    
      attending = fan.friends_going(show)
    
      attending_friends = attending.map { |fan| 
      "<a href=\""+ item_url(fan)+ "\">"+fan.name+"</a>"
        }.join(" / ")
      
      if attending_friends.size > 0
        desc << "<p><b>Friends Interested:</b> #{attending_friends}</p>"
      end
    end
    
    desc << "<p><a href=\"#{item_url(show)}\">More details...</a></p>"
    
    xml << "<description>#{cdata_escape(desc)}</description>"
    return xml
  end
  
  # Format a Comment
  def xml_for_comment(comment)
    xml = ""
    xml << "<title>Comment from #{h(comment.created_by_name)}</title>"
    xml << "<pubDate>#{rss_format_time(comment.created_on)}</pubDate>"
    xml << "<link>#{item_url(comment)}</link>"
    xml << "<description>#{cdata_escape(simple_format( h(sanitize(comment.body))))}</description>"
    return xml
  end
  
  # Format a Photo
  def xml_for_photo(photo)
    xml = ""
    xml << "<title>Photo from #{photo.created_by_name}</title>"
    xml << "<pubDate>#{rss_format_time(photo.created_on)}</pubDate>"
    xml << "<link>#{item_url(photo)}</link>"
    
    s = "<img src=\"" + public_photo_url(photo, "preview") + "\"/>"
    s << "<br/>#{simple_format(h(sanitize(photo.description)))}"

    xml << "<description>#{cdata_escape(s)}</description>"
    return xml
  end  
  
  # Wrap description in CDATA to allow embedding HTML
  def cdata_escape(str)
    return "<![CDATA[#{str}]]>"
  end
  
end