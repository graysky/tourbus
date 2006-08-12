## 
#
# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

#
# The URL for this site - mandatory
# Can be single url:
set :url, "http://www.auntiemaes.com/calendar.htm"
#
set :display_name, "Auntie Mae's Parlor"

# How often (in hours) to check the site (can set to 0 to force checking everytime)
set :interval, 72

# Use the table parser 
set :parser_type, :table

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================

# Table columns for the shows
set :table_columns, { 0 => :date, 2 => :bands, 3 => :time }

# Comma separates bands
set :band_separator, "<br>"
set :use_raw_bands_text, true
set :marker_text, ['Thur']

method :preprocess_bands_text, {:args => 1} do |text|
  text.gsub(/w\//, '')
end

# All shows for this site are at the same venue
method :get_venue do
  { :id => 1242 } 
end
