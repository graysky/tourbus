#
# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

#
# The URL for the site
set :url, "http://ticketweb.com/user/?region=socal&query=schedule&venue=echo"

set :display_name, "TicketWeb"
set :parser_type, :ticket_web
set :quality, 3

# Define "venue_id" in the site.rb file
method :get_venue do
  { :id => 942 } 
end

method :links_to_follow, {:args => 1} do |xml_doc|
  TicketWebParser.links_to_follow(xml_doc)
end