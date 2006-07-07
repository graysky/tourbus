#
# =============================================================================
# REQUIRED VARIABLES
# =============================================================================
#
# The URL for this site - mandatory
# Can be single url:
urls = []
page = 1
base = "http://socallist.com/shows/page"
10.times do 
  urls << base + page.to_s
  page += 1
end

set :url, urls

set :display_name, "So-Cal List"

set :quality, 4
# How often (in hours) to check the site (can set to 0 to force checking everytime)
set :interval, 72
# Use custom parser
set :parser_type, :socallist


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