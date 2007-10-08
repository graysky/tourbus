require 'rexml/document'
require 'parsedate'
require 'yaml'
require 'anansi/lib/rexml' # TEMP
require 'anansi/lib/show_parser' # TEMP
require 'anansi/lib/string' # TEMP

class JambaseParser < TableParser
  include REXML
  
  def parse    
    @marker_text = ['Location']
    table = find_table
    
    date = nil
    k = 0
    table.each do |row|
      
      if row.is_a?(Element) && row.name == 'tr'
        
        #next if k > 6 # TODO DEBUGGING REMOVE ME!
        k = k + 1
        contents = row.children[1].recursive_text
        
        contents.gsub!(/\n/, "")
        
        if contents =~ /(\d\d\/\d\d\/\d\d)(.*)::/
          date = parse_as_date($1.strip, false) rescue nil
          #puts "Parsed date: #{date}"
          next if date.nil?
        else
          
          # Basic show format is:
          # <tr>
          # <td class='artistCol'>
          # ... Band 1 ... <br/>
          # ... Band 2 ... etc.
          # <td class='venueCol'>
          # ... Venue name ...
          # 
          
          @show = {}
          @show[:bands] = []
          @show[:date] = date.to_s
          @show[:venue] = get_venue
          @show[:time] = "7pm" 
          
          row.each do |cell|
            
            # Stuff to skip
            next if !cell.is_a?(Element)
            next if cell.to_s =~ /td class='iconCol'/
            next if cell.to_s =~ /td class='toolCol'/
            
            # Pull out band names
            if cell.to_s =~ /td class='artistCol'/
              bands = cell.recursive_text
              
              j = 0
              bands.split(/\n/).each do |b|
                band = probable_band(b, j, nil)
                @show[:bands] << band if band
                j = j+1
              end            
            end
            
            # Pull out venue name
            if cell.to_s =~ /td class='venueCol'/
              venue = cell.recursive_text.strip
              @show[:venue][:name] = venue
            end
            
            # Pull out city, state
            if cell.to_s =~ /td class='locationCol'/
              loc = cell.recursive_text.strip.split(",")
              
              @show[:venue][:city] = loc[0].gsub(/\n/, ' ').strip
              @show[:venue][:state] = loc[1].strip
              
              next if @show[:bands].empty?
              puts "Show is #{@show.to_yaml}\n\n"
              @shows << @show
            end
            
          end
          
        end #if contents
      end # if row_
    end #table.each
    @shows
  end #parse
  
end