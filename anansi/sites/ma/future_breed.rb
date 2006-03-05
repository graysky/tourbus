## 
## Anansi config file for the future breed website

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

#
# The URL for this site - mandatory
# Can be single url:
set :url, "http://futurebreed.50webs.com/shows.htm"
#

# How often (in hours) to check the site (can set to 0 to force checking everytime)
set :interval, 72

# Use the table parser 
set :parser_type, :multi_table

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
#

set :table_columns,  { 0 => :bands, 1 => :venue_name, 2 => :venue_location, 3 => [:time, :age_limit, :cost] }

# =============================================================================
# DEFINE METHODS
# =============================================================================
#
