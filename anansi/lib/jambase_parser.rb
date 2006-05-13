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
      if child.name == 'tr'
        contents = child.children[0].recursive_text
        if contents =~ /.*::(.*)::.*/
          date = parse_as_date($1.strip)
        else
          
          @show = {}
          @show[:bands] = []
          @show[:date] = date
          @show[:time] = "7pm"     
          
          ul = child.children[0].find_node_by_text('ul')
          next if ul.nil?
          
          i = 0
          ul.each do |li|
            band = probable_band(li.recursive_text, i, nil)
            @show[:bands] << band if band
              
            i += 1
          end
          
          next if @show[:bands].empty?
          
          @show[:venue] = { :name => child.children[1].recursive_text.strip }
            
          puts "Show is #{@show.to_yaml}\n\n"
          @shows << @show
        end
      end
    end
  end
  
end