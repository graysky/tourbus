## 
## Anansi config file for The Paradise in Boston
#
# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

#
# The URL for this site - mandatory
# Can be single url:
set :url, "http://www.teapartyconcerts.com/venues.html?venueID=371"
#

# How often (in hours) to check the site (can set to 0 to force checking everytime)
set :interval, 72

# Use the table parser 
set :parser_type, :table

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
#

# Table columns for the shows
set :table_columns, { 0 => [:date, :time], 1 => :bands}

# Text to mark the shows table
set :marker_text, ["Event Title"]

# TODO Need way to indicate each show is happening at the same venue

# =============================================================================
# DEFINE METHODS
# =============================================================================
#
method :preprocess_bands_text, {:args => 1} do |text|
  # The first "with" is probably a separator
  text.sub(/with/, ',')
end
