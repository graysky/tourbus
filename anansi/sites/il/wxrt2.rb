# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

#
# The URL for this site - mandatory
# Can be single url:
now = Time.now
month = now.month + 1
month = 1 if month == 13
set :url, "http://www.wxrt.com/artists/concerts.html?month_id=#{month}"

#
set :display_name, "WXRT Radio"
# How often (in hours) to check the site (can set to 0 to force checking everytime)
set :interval, 72

# Use the table parser 
set :parser_type, :table

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
#

# Table columns for the shows
set :table_columns, { 0 => :date, 1 => :bands, 2 => :venue, 3 => [:time, :age_limit, :cost] }

# Comma separates bands
set :band_separator, '/'

set :marker_text, 'Time/Price'

# =============================================================================
# DEFINE METHODS
# =============================================================================
#
method :preprocess_bands_text, {:args => 1} do |text|
  text ? text.gsub('w/', '/') : text
end
