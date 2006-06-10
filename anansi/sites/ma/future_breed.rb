## 
## Anansi config file for the future breed website

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

#
# The URL for this site - mandatory
# Can be single url:
set :url, "http://futurebreed.50webs.com/shows.htm"
#
set :display_name, "Future Breed"
# How often (in hours) to check the site (can set to 0 to force checking everytime)
set :interval, 72

# Use the table parser 
set :parser_type, :multi_table

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
#

set :table_columns,  { 0 => :bands, 1 => :venue_name, 2 => :venue_location, 3 => [:time, :age_limit, :cost] }

# =============================================================================
# DEFINE METHODS
# =============================================================================
#
method :before_parse_bands, {:args => 2} do |cell, contents|
  # Awkward paragraph placement
  if cell.elements[1].name == 'p'
    @show[:preamble] = cell.elements[1].recursive_text.strip
    cell.elements[1].remove
  elsif cell.elements[1].name == 'div' and cell.elements[1].elements[1] and cell.elements[1].elements[1].name == 'p'
    @show[:preamble] =cell.elements[1].elements[1].recursive_text.strip
    cell.elements[1].elements[1].remove
  end
end
