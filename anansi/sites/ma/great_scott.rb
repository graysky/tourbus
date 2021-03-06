## 
## Anansi config file for Great Scott in Allston
#
# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

#
# The URL for this site - mandatory
# Can be single url:
set :url, "http://www.greatscottboston.com/main.cgi"
#
set :display_name, "Great Scott"
# How often (in hours) to check the site (can set to 0 to force checking everytime)
set :interval, 72

# Use the table parser 
set :parser_type, :table

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
#

# Table columns for the shows
set :table_columns, { 0 => :date, 1 => :ignore, 2 => :bands, 3 => :time_age_cost }

# Comma separates bands
set :band_separator, '<br>'

# =============================================================================
# DEFINE METHODS
# =============================================================================
#
# All shows for this site are at the same venue
method :get_venue do
  { :name => "Great Scott", :city => "Allston", :state => "MA" } 
end