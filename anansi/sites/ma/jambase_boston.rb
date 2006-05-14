## 
## Anansi config file for The Middle East in Cambridge
#
# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

#
# The URL for this site - mandatory
# Can be single url:
set :url, "http://www.jambase.com/search.asp?city=Boston&stateID=21&dispall=1"
#

set :quality, 4

# How often (in hours) to check the site (can set to 0 to force checking everytime)
set :interval, 72

# Use the table parser 
set :parser_type, :jambase

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
#

# =============================================================================
# DEFINE METHODS
# =============================================================================
#
# All shows for this site are at the same venue
method :default_time do
  "7pm"
end
