## 
## Anansi config file for the blank club in SF
#
# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

#
# The URL for this site - mandatory
# Can be single url:
set :url, "http://ae.mercurynews.com/entertainment/ui/mercurynews/venue.html?id=11"
set :display_name, "The Mercury News"
set :quality, 2

# How often (in hours) to check the site (can set to 0 to force checking everytime)
set :interval, 72

# Use the table parser 
set :parser_type, :table

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
#

# Table columns for the shows
set :table_columns, { 0 => :bands, 1 => :date, 2 => :cost }

# Comma separates bands
set :band_separator, ','


# =============================================================================
# DEFINE METHODS
# =============================================================================
#
method :get_venue do
  { :id => 644 } 
end