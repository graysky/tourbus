require 'rexml/document'
require 'parsedate'
require 'yaml'
require 'anansi/lib/rexml' # TEMP
require 'anansi/lib/show_parser' # TEMP
require 'anansi/lib/string' # TEMP

# ULGY parser for the mideast.
class MidEastParser < ShowParser
  include REXML
  
  def parse
    @doc.root.each_element("//p") do |p|
      begin
        @show = {}
        @show[:date] = parse_as_date(p.children[0].to_s)
        
        str = p.children[2..p.children.size].map  do |child|
          child.respond_to?(:recursive_text) ? child.recursive_text : child.to_s.strip
        end.join(" ")
        
        bands = []
        index = 0
        chunks = str.split(",")
        chunks.each do |chunk|
          if index == 0 and index != chunks.size - 1
            # Look out for the dashes before the first band, but not in parens!
            temp = chunk.gsub(/(\((.)*\))/, '').split("-")
            if temp.size > 1
              chunk = temp.last.strip
              @show[:preamble] = temp[0..(temp.size - 2)].join(" ")
            end
          else
            sep = chunk.index("&nbsp;")
            chunk = chunk[0..(sep - 1)] if sep
            
            sep = chunk.index(" -") || chunk.index("&#8211;")
            chunk = chunk[0..(sep - 1)]  if sep
            
            sep = chunk.index("18+") || chunk.index("All Ages")
            chunk = chunk[0..(sep - 1)]  if sep
          end
          
          band = probable_band(chunk, index, p)
          bands << band if band  
          index += 1  
        end
        
        raise "\nNo bands on #{@show[:date]}, #{str}\n" if bands.empty?
        
        @show[:bands] = bands
        @show[:age] = parse_as_age_limit(str)
        @show[:cost] = parse_as_cost(str)
        time = parse_as_time(str)
        @show[:time] = time || default_time
        
        if @show[:venue].nil?
          @show[:venue] = get_venue
        end
        
        puts "Show is #{@show.to_yaml}\n\n"
        @shows << @show
      rescue Exception => e
        #puts e
        #puts e.backtrace
      end
    end
    
    @shows
  end
  
  def default_time
    "8pm"
  end
end