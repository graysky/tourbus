#
# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

#
# The URL for the site
set :url, "http://ticketweb.com/user/?region=ma&query=schedule&venue=scullers"

set :display_name, "TicketWeb"
set :parser_type, :ticket_web
set :quality, 3

# Define "venue_id" in the site.rb file
method :get_venue do
  { :id => 140 } 
end

method :links_to_follow, {:args => 1} do |xml_doc|
  TicketWebParser.links_to_follow(xml_doc)
end