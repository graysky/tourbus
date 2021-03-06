## 
## Anansi config file for the future breed website

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

#
# The URL for this site - mandatory
# Can be single url:
set :url, "http://futurebreed.50webs.com/show_listings.htm"
#
set :display_name, "Future Breed"
# How often (in hours) to check the site (can set to 0 to force checking everytime)
set :interval, 72

# Use the table parser 
set :parser_type, :table
set :band_separator, ','
set :marker_text, ['EXTRA INFO']

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
#

set :table_columns,  { 0 => :date, 1 => :bands, 2 => :venue_name, 3 => :venue_location, 4 => [:time, :age_limit, :cost] }

# =============================================================================
# DEFINE METHODS
# =============================================================================
#
