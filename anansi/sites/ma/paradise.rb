## 
## Anansi config file for The Paradise in Boston
#
# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

#
# The URL for the site
# Can be single url:
set :url, "http://www.teapartyconcerts.com/venues.html?venueID=371"
#
set :display_name, TeapartyHelper::DISPLAY_NAME
# How often (in hours) to check the site (can set to 0 to force checking everytime)
set :interval, 72

# Use the table parser 
set :parser_type, :table

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
#

# Table columns for the shows
set :table_columns, TeapartyHelper.table_columns

# Comma separates bands
set :band_separator, TeapartyHelper.band_separator

# Text to mark the shows table
set :marker_text, TeapartyHelper.marker_text

# TODO Need way to indicate each show is happening at the same venue

# =============================================================================
# DEFINE METHODS
# =============================================================================
#

method :preprocess_bands_text, {:args => 1} do |text|
  TeapartyHelper.preprocess_bands_text(text)
end

# All shows for this site are at the same venue
method :get_venue do
  { :name => "Paradise Rock Club", :city => "Boston", :state => "MA" } 
end
