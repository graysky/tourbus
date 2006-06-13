require 'icalendar'

# Helpers for producing iCalendar feed
module Ical
  
  # Return the icalendar contents as a string
  def get_ical(shows)  
    cal = Icalendar::Calendar.new
    cal.prodid = "tourb.us iCalendar feed"
    
    shows.each do |show|
      event = Icalendar::Event.new
      
      # Set some properties for this event
      event.timestamp = DateTime.now
    
      # Need to convert from Time to DateTime to pick up
      # the to_ical method
      event.start = get_datetime(show.date)
      event.end = get_datetime(show.date + show.bands.size.hours)
      event.summary = escape_string(show.name)
      event.location = escape_string(show.venue.name)
      event.description = show.description
      event.url = public_show_url(show)

      # Add it to the calendar
      cal.add event
    end
    
    return cal.to_ical
  end
  
  private
  
  # Convert a Time to DateTime
  def get_datetime(t)
    d = DateTime.civil(t.year, t.mon, t.day, t.hour, t.min, t.sec)
    return d
  end
  
  def escape_string(s)
    s.gsub!('&#8217;','\'') # Single appos
    return s
  end
  
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
  
end