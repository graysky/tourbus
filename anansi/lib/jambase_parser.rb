require 'rexml/document'
require 'parsedate'
require 'yaml'
require 'anansi/lib/rexml' # TEMP
require 'anansi/lib/show_parser' # TEMP
require 'anansi/lib/string' # TEMP

class JambaseParser < TableParser
  include REXML
  
   def parse    
    @marker_text = ['BAND(S)']
    table = find_table
    
    date = nil
    
    table.each do |child|
      if child.is_a?(Element) && child.name == 'tr'
        contents = child.children[1].recursive_text
        if contents =~ /.*::(.*)::.*/
          date = parse_as_date($1.strip, false) rescue nil
          next if date.nil?
        else
          
          @show = {}
          @show[:bands] = []
          @show[:date] = date
          @show[:time] = "7pm"     
          
          ul = child.children[1].find_node_by_text('ul')
          next if ul.nil?
          
          i = 0
          ul.each_element do |li|
            band = probable_band(li.recursive_text, i, nil)
            @show[:bands] << band if band
              
            i += 1
          end
          
          next if @show[:bands].empty?
          
          @show[:venue] = get_venue
          @show[:venue][:name] = child.elements[2].recursive_text.strip
          loc = child.elements[3].recursive_text.split(",")
          @show[:venue][:city] = loc[0].strip
          @show[:venue][:state] = loc[1].strip
          
          # Grab the venue url, which can be used by venue importers
          @show[:venue][:detail_link] = child.elements[1].find_node_by_text("a").attributes["href"]
          
            
          puts "Show is #{@show.to_yaml}\n\n"
          @shows << @show
        end
      end
    end
  end
  
end