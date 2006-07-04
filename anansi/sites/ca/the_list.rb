## 
## Anansi config file for The List for SF
#
# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

#
# The URL for this site - mandatory
# Can be single url:
set :url, "http://jmarshall.com/events/findevents.cgi"
#
set :display_name, "The List"
set :display_url, "http://www.calweb.com/~skoepke/"
# How often (in hours) to check the site (can set to 0 to force checking everytime)
set :interval, 72

# Use the table parser 
set :parser_type, :table

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
#

# Table columns for the shows
set :table_columns, { 0 => [:date, :time], 1 => :bands, 2 => :venue, 3 => :cost }

# Comma separates bands
set :band_separator, ','


# =============================================================================
# DEFINE METHODS
# =============================================================================
#
method :preprocess_bands_text, {:args => 1} do |text|
  # Sometimes slashes sneak in
  text.sub(/\//, ',')
end

method :parse_venue, {:args => 2} do |cell, contents|
  @show[:venue] ||= {}
  chunks = contents.split(",")
  @show[:venue][:name] = chunks[0].strip
  
  if chunks.size > 1
    loc = chunks[1..(chunks.size - 1)].join(", ")
    loc.gsub!(/s\.f\./i, 'San Francisco')
    @show[:venue][:city] = loc.strip
  end
  
  @show[:state] = 'CA'
  @show[:region] = 'bay area'
end