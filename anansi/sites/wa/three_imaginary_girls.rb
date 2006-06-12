## 
#
# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

#
# The URL for this site - mandatory
# Can be single url:
set :url, "http://www.threeimaginarygirls.com/calendar.asp"
#
set :display_name, "Three Imaginary Girls"

# How often (in hours) to check the site (can set to 0 to force checking everytime)
set :interval, 72

set :parser_type, :three_girls

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
#

# Table columns for the shows
set :table_columns, { 0 => :date, 2 => :bands, 4 => :time }

# Comma separates bands
set :band_separator, ','
set :use_raw_bands_text, true
set :marker_text, ['Doors']

# =============================================================================
# DEFINE METHODS
# =============================================================================
#
method :preprocess_bands_text, {:args => 1} do |text|
  HTML::strip_all_tags(text.gsub('<br>', ',').gsub('<br/>', ','))
end

# All shows for this site are at the same venue
method :get_venue do
  { :id => 172 } 
end