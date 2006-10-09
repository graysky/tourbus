## 
## Anansi config file for Black Cat
#
# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

#
# The URL for this site - mandatory
# Can be single url:
set :url, "http://www.blackcatdc.com/schedule.html"
#
set :display_name, "Black Cat"
# How often (in hours) to check the site (can set to 0 to force checking everytime)
set :interval, 72

# Use the table parser 
set :parser_type, :black_cat

# Table columns for the shows
#set :table_columns, { 0 => :date, 1 => :ignore, 2 => :bands, 3 => :time_age_cost }

# Comma separates bands
set :band_separator, '<br><br>'

# All shows for this site are at the same venue
method :get_venue do
  { :id => 953 } 
end