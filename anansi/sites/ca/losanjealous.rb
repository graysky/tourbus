#
# =============================================================================
# REQUIRED VARIABLES
# =============================================================================
#
# The URL for this site - mandatory
# Can be single url:
set :url, "http://www.losanjealous.com/shows/"

set :display_name, "Losanjealous"

# Site often only has 1 or 2 of the bands playing
set :quality, 1
# How often (in hours) to check the site (can set to 0 to force checking everytime)
set :interval, 72
# Use custom parser
set :parser_type, :losanjealous #:table

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
#
# Table columns for the shows
set :table_columns, { 1 => :date, 2 => :bands }

set :marker_text, [Time.now.strftime("%B").upcase!]

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

method :get_venue do
  { :region => 'la' } 
end