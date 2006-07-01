#
# =============================================================================
# REQUIRED VARIABLES
# =============================================================================
#
# The URL for this site - mandatory
# Can be single url:
set :url, "http://www.casenet.com/music/clubsall.htm"

set :display_name, "CaseNet"

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
set :table_columns, { 0 => :date, 1 => :venue, 2 => :bands }

set :marker_text, ['Sorted by']

# =============================================================================
# DEFINE METHODS
# =============================================================================
#
# Note: This site uses BOTH commas and br tags - ugh. By default,
# parser looks for br tag and replaces them with "|" seperators. 
# So let it do that, and then we clean up the commas and replace them too.
# 
method :preprocess_bands_text, {:args => 1} do |text|
  text
end