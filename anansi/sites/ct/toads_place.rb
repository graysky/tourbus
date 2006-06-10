## 
#
# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

#
# The URL for this site - mandatory
# Can be single url:
set :url, "http://www.toadsplace.com/calendar.htm"
#
set :display_name, "Toad's Place"

# How often (in hours) to check the site (can set to 0 to force checking everytime)
set :interval, 72

# Use the table parser 
set :parser_type, :table

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================

# Table columns for the shows
set :table_columns, { 0 => :date, 1 => :bands, 2 => :time }

# Comma separates bands
set :band_separator, nil
set :use_raw_bands_text, true
set :marker_text, ['York Street']

method :preprocess_bands_text, {:args => 1} do |text|
  blah = HTML::strip_all_tags(text.gsub('<br>', ',').gsub('<br/>', ','))
  #blah.gsub!(' ', '_')
  blah.gsub!("\r", '|')
  blah.gsub!("\n", '|')
  #puts "Band text is: [#{blah}]"
end

# All shows for this site are at the same venue
method :get_venue do
  { :name => "Toad's Place", :city => "New Haven", :state => "CT" } 
end
