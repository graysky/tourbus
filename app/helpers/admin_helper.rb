module AdminHelper
  def show_import_hash(show)
    return if show[:date].nil?
    
    out = ''
    out << row("Site", show[:site])
    out << row("Explanation", show[:explanation])
    out << row("Date", friendly_date(show[:date]).to_s + ", " + friendly_time(show[:date]).to_s)
    out << row("Cost", show[:cost])
    out << row("Age", show[:age])
    out << row("Preamble", show[:preamble])
    out << row("Sold Out", show[:soldout]) if show[:soldout]
    out << row("Cancelled", show[:cancelled]) if show[:cancelled]
    out << row("Ticket Link", show[:ticket_link]) if show[:ticket_link]
    out << row("Worker", show[:worker]) if show[:worker]
    
    venue = ''
    show[:venue].each do |key, value|
      venue += "#{key}=#{value}, "
    end
    out << row("Venue", venue[0..(venue.size - 3)])
    
    bands = ''
    show[:bands].each do |band|
      bands += "<u>#{band[:name]}</u>"
      bands += ", <a href='#{band[:url]}'>#{band[:url]}</a>" if band[:url]
      bands += ", (#{band[:extra]})" if band[:extra]
      bands += "<br/>"
    end
    out << row("Bands", bands)
    
  end
  
  def import_show_form(show)
    out = ''
    out << row("Site", show[:site])
    out << row("Explanation", show[:explanation])
    out << row("Date", friendly_date(show[:date]).to_s + ", " + friendly_time(show[:date]).to_s)
    out << row("Cost", text_field_tag('cost', show[:cost]))
    out << row("Age", text_field_tag('age', show[:age]))
    out << row("Preamble", text_field_tag('preamble', show[:preamble]))
    
    venue = '<table>'
    if show[:venue][:id].nil?
      venue << row("id", text_field_tag('venue_id', ''))
    end
    show[:venue].each do |key, value|
      venue << row(key, text_field_tag("venue_#{key}", value))
    end
    venue << '</table>'
    out << row("Venue", venue)
    
    bands = '<table>'
    count = 0
    show[:bands].each do |band|
      bands << row("Name", text_field_tag("band#{count}_name", band[:name]))
      bands << row("URL", text_field_tag("band#{count}_url", band[:url]))
      bands << row("Extra", text_field_tag("band#{count}_extra", band[:extra]))
      bands << '<tr><td/><td/></tr>'
      count += 1
    end
    bands << '</table>'
    out << row("Bands", bands)
    
  end
  
  private
  
  def row(label, value)
    "<tr><td valign='top'><b>#{label}:</b></td><td>#{value}"
  end
end
