## 
## Anansi config file for TTs in Cambridge
#
# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

#
# The URL for this site - mandatory

now = Time.now
month = now.month
year = now.year
set :url, "http://ttthebears.com/public/calendar.php?month=#{month}&year=#{year}"
set :display_name, "TT The Bear's"
# How often (in hours) to check the site (can set to 0 to force checking everytime)
set :interval, 72


# Use the table parser 
set :parser_type, :tts

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
