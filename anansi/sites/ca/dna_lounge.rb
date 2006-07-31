#
# =============================================================================
# REQUIRED VARIABLES
# =============================================================================
#
# The URL for this site - mandatory
# Can be single url:
set :url, "http://www.dnalounge.com/calendar/dnalounge.rss"

# Pulling a feed
set :xml, true

set :display_name, "DNA Lounge"

set :quality, 2
# How often (in hours) to check the site (can set to 0 to force checking everytime)
set :interval, 72
# Use the table parser 
set :parser_type, :dna_lounge

# All at the DNA Lounge
method :get_venue do
  { :id => 330 } 
end