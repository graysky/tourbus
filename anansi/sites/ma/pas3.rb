## 
## Anansi config file for TTs in Cambridge
#
# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

#
# The URL for this site - mandatory

now = Time.now
month = now.month + 2
month = 1 if month == 13
month = 2 if month == 14
year = (month == 1 or month == 2) ? now.year + 1 : now.year

set :url, "http://paslounge.com/pas_cal.cgi?cvm=#{month}&cvy=#{year}"

# How often (in hours) to check the site (can set to 0 to force checking everytime)
set :interval, 72
 
set :parser_type, :pas

set :month, month
set :year, year

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
#

# TODO Need way to indicate each show is happening at the same venue

# =============================================================================
# DEFINE METHODS
# =============================================================================
#
# All shows for this site are at the same venue

method :default_time do
  "9pm"
end
