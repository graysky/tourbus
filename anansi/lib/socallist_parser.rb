require 'rexml/document'
require 'parsedate'
require 'yaml'
require 'anansi/lib/rexml' # TEMP
require 'anansi/lib/show_parser' # TEMP
require 'anansi/lib/string' # TEMP

class SocallistParser < ShowParser
  include REXML
  
  def parse
    @shows = []
    
    @doc.root.each_element("//a") do |link|
      if link.text && link.text.strip  =~ /^\d(\d)?-\d(\d)?-\d\d/
        
        @show = {}
        @show[:date] = parse_as_date(link.text, false)
        @show[:bands] = [] 
        
        state = :start
        band_index = 0
        elem = link.next_sibling
        while elem
          text = elem.to_s.strip
          
          if text.starts_with?("::")
            state = case state
              when :start then :bands
              when :bands then :venue
              when :venue then :other
            end
           
            if state == :other
              @show[:age_limit] = parse_as_age_limit(text)
              @show[:time] = parse_as_time(text)
              @show[:cost] = parse_as_cost(text)
              break
            end
          elsif state == :bands
            if elem.is_a?(Element) && elem.name == "a"
              band = probable_band(elem.recursive_text, band_index, nil)
              @show[:bands] << band if band
              
              band_index += 1
            end
          elsif state == :venue
            @show[:venue] = get_venue
            @show[:venue][:name] = elem.recursive_text.strip
          end
          
          elem = elem.next_sibling
        end
        
        @shows << @show
      end
    end
   
    @shows
  end
  
end