# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

#
# The URL for this site - mandatory
# Can be single url:
now = Time.now
month = now.month + 3
month = 1 if month == 13
month = 2 if month == 14
month = 3 if month == 15
year = (month == 1 or month == 2) ? now.year + 1 : now.year

set :url, "http://www.jambase.com/Shows/Shows.aspx?ArtistID=0&VenueID=0&City=Los%20Angeles&State=CA&Zip=&radius=50&StartDate=#{now.month}/#{now.day}/#{now.year}&EndDate=#{month}/28/#{year}&Rec=False&pagenum=1&pasi=1500"

#set :url, "http://www.jambase.com/search.asp?city=Los%20Angeles&stateID=5&beyondCity=1&dispall=1"
#
set :display_name, "Jambase"
set :quality, 1
set :use_tidy, true

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

method :get_venue do
  { :region => 'la' } 
end