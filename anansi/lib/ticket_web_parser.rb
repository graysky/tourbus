require 'rexml/document'
require 'parsedate'
require 'yaml'
require 'anansi/lib/rexml' # TEMP
require 'anansi/lib/show_parser' # TEMP
require 'anansi/lib/string' # TEMP

class TicketWebParser < TableParser
  include REXML
  
  def initialize(xml, url = nil)
    super
    @marker_text = "Buy"
    @table_columns = { 2 => [:time, :date, :cost, :bands] }
  end

  # Special parse_bands to pull out venue from band info
  def parse_bands(cell, contents)
    text = preprocess_bands_text(cell.children[3].to_s)
    text.sub!(/plus/, "/")
    text.sub!(/with/, "/")
    text.sub!(/featuring/, "/")
   
    bands = []
    text.split("/").each_with_index do |chunk, index|
      band = probable_band(chunk, index, nil)
      
      if band
        bands << band
      end
    end
    
    raise "No bands" if bands.empty?
    
    @show[:bands] = bands
  end
  
  def self.links_to_follow(xml_doc)
    more = XPath.first(xml_doc, "//img[@src='http://i.ticketweb.com/images/more_events.gif']")
    if more
      link = more.parent
      [link.attributes["href"]]
    else
      nil
    end
  end
  
end