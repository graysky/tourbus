#
# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

#
# The URL for the site
set :url, "http://www.livenation.com/feed/venuefeed/venueid/11237"

set :display_name, "Live Nation"
set :parser_type, :live_nation
set :quality, 3
set :xml, true

# Define "venue_id" in the site.rb file
method :get_venue do
  { :id => 124 } 
end