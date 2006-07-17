require 'rexml/document'
require 'parsedate'
require 'yaml'
require 'anansi/lib/rexml' # TEMP
require 'anansi/lib/show_parser' # TEMP
require 'anansi/lib/string' # TEMP

class LiveNationParser < ShowParser
  include REXML
  
  def parse
    @shows = []
    @doc.root.each_element("//item") do |item|
      @show = {}
      @show[:venue] = get_venue
      @show[:bands] = []
      @show[:time] = "7pm"
      
      @show[:source_link] = item.elements[2].recursive_text
      
      text = item.elements[3].text
      bands = text[0, text.index('--')]
      bands = bands.gsub(/\//, ',').split(',')
      
      bands.each_with_index do |band, i|
        band = probable_band(band, i, nil)
        @show[:bands] << band if band
      end
      
      @show[:date] = parse_as_date(text[text.index('--'),  text.length])
      next unless @show[:date]
  
      @shows << @show
    end
    
    @shows
  end
end