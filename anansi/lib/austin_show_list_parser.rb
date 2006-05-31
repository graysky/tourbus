require 'rexml/document'
require 'parsedate'
require 'yaml'
require 'anansi/lib/rexml' # TEMP
require 'anansi/lib/show_parser' # TEMP
require 'anansi/lib/string' # TEMP

class AustinShowListParser < ShowParser
  include REXML
  
  def parse
  
    @doc.root.each_element("//li") do |li|
      next if li.text == '' || li.text == "\n"
      
      begin
        @show = {}
        @show[:bands] = []
        
        date_str = li.parent.previous_sibling.previous_sibling.recursive_text
        @show[:date] = parse_as_date(date_str, true)
        
        contents = li.text
        
        # Bands go until the last "at"
        index = contents.length - contents.reverse.index('ta')
        bands_str = contents.slice(0, index - 2)
        bands_str.split(",").each_with_index do |name, i|
          band = probable_band(name, i, nil)
          @show[:bands] << band if band
        end
        
        next if @show[:bands].empty?
        
        link = li.find_node_by_text("a", nil)
        next if link.nil?
        
        @show[:venue] = { :name => link.recursive_text.strip, :state => 'TX' }
        @show[:time] = '7pm'
        
        p @show
        @shows << @show
        
      rescue Exception => e
        # ignore
        p e
      end
      
      @shows
    end
  end
  
end