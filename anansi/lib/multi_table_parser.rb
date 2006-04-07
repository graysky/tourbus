require 'rexml/document'
require 'parsedate'
require 'yaml'
require 'anansi/lib/rexml' # TEMP
require 'anansi/lib/table_parser' # TEMP
require 'anansi/lib/string' # TEMP

# Parses a bunch of tables (parseable by TablParser) separate by something.
# For now, assume that something is a date.
class MultiTableParser < TableParser
  
  def parse
    # Find the first table
    table = find_table
    raise "Didn't find table" if table.nil?
    
    @nested = false
    
    # Iterate over the children of the parent, in order.
    date = nil
    all_shows = []
    table.parent.each_element do |elem|
      if elem.name == "table"
        next if date.nil?
        
        @shows = []

    	# The root is the table
        self.root = elem
        new_shows = super
        
    	# Set the date on each show
        new_shows.each do |show|
          show[:date] = date
          all_shows << show
        end
      else
        # TODO This wil need to be extended
        date = parse_as_date(elem.recursive_text, false)
      end
    end
    
    @shows = all_shows
  end
  
end