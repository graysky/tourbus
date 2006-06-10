## 
## Anansi config file for The Middle East in Cambridge
#
# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

#
# The URL for this site - mandatory
# Can be single url:
set :url, "http://mideastclub.com/up-schedule.html"
#
set :display_name, "The Middle East"
# How often (in hours) to check the site (can set to 0 to force checking everytime)
set :interval, 72

set :leave_nbsps, true

# Use the table parser 
set :parser_type, :mideast

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
#

# =============================================================================
# DEFINE METHODS
# =============================================================================
#
# All shows for this site are at the same venue
method :get_venue do
  { :name => "The Middle East (upstairs)", :city => "Cambridge", :state => "MA" } 
end

method :default_time do
  "9pm"
end
