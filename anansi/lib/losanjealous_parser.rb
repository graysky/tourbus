require 'rexml/document'
require 'parsedate'
require 'yaml'
require 'anansi/lib/rexml' # TEMP
require 'anansi/lib/show_parser' # TEMP
require 'anansi/lib/string' # TEMP

class LosanjealousParser < TableParser
  include REXML
  
  def initialize(xml, url = nil)
    super
  end

  # Special parse_bands to pull out venue from band info
  def parse_bands(cell, contents)
    # Split into 2 chunks:
    # 0 => band names
    # 1 => venue
    chunks = contents.split('@')
    
    # Pull out band names
    bands = []
    cell_index = 0
    
    chunks[0].split(',').each do |chunk|
    
      band = probable_band(chunk, cell_index, cell)
      if band
        bands << band
      else
        puts "**** Not a band: #{chunk}"
      end
      cell_index += 1
    end
    
    raise "No bands" if bands.empty?
    
    @show[:bands] = bands

    venue_name = chunks[1]
    # Remove "(free)" from venue name
    venue_name.gsub!(/\(free\)/,'')
    
    # Pull out venue
    @show[:venue] ||= get_venue
    @show[:venue][:name] = venue_name.strip
  end
  
end