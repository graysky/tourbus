# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

#
# The URL for this site - mandatory
# Can be single url:
set :url, "http://www.mtv.com/music/tours/results.jhtml?city=Boston&countryID=161"

#
set :display_name, "MTV"
# How often (in hours) to check the site (can set to 0 to force checking everytime)
set :interval, 72

set :quality, 2

# Use the table parser 
set :parser_type, :table

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
#

# Table columns for the shows
set :table_columns, { 0 => :date, 2 => :bands, 4 => :venue }

# Comma separates bands
set :band_separator, '/'

set :marker_text, 'Axis'

# =============================================================================
# DEFINE METHODS
# =============================================================================
#
method :default_time do
  "7pm"
end