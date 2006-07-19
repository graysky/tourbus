#
# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

#
# The URL for the site
set :url, "http://www.ticketweb.com/user?region=chicago&query=schedule&venue=beatkitch"

set :display_name, "TicketWeb"
set :parser_type, :ticket_web
set :quality, 3

# Define "venue_id" in the site.rb file
method :get_venue do
  { :id => 878 } 
end

method :links_to_follow, {:args => 1} do |xml_doc|
  more = XPath.first(xml_doc, "//img[@src='http://i.ticketweb.com/images/more_events.gif']")
  if more
    link = more.parent
    [link.attributes["href"]]
  else
    nil
  end
end