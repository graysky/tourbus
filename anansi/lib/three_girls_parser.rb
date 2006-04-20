require 'rexml/document'
require 'parsedate'
require 'yaml'
require 'anansi/lib/rexml' # TEMP
require 'anansi/lib/show_parser' # TEMP
require 'anansi/lib/string' # TEMP

class ThreeGirlsParser < ShowParser
  include REXML
  
  def parse
  
    @doc.root.each_element("//b") do |start|
      date_str = start.recursive_text
      date = parse_as_date(date_str, false)
      next if date.nil?
      
      elem = start
      brs = 0
      while !elem.nil?
        elem = elem.next_sibling
        break if elem.nil?
        next if elem.is_a?(Text)
        
        elem.name == 'br' ? brs += 1 : brs = 0
        break if brs == 2
        
        if elem.name == 'li'
          @show = {}
          @show[:bands] = []
          @show[:date] = date
      
          text = elem.text.gsub('*', '').gsub('{', '(').gsub('}', ')').gsub('/', ',')
          chunks = text.split(',')
          chunks.each_with_index do |chunk, index|
            if chunk == chunks.last
              # This is the venue
              if chunk =~ /\((.*)\)/
                @show[:time] = parse_as_time($1, false)
                chunk = chunk[0..(chunk.index('(')) - 1]
              end
              
              @show[:venue] = {}
              @show[:venue][:name] = chunk.strip
              @show[:venue][:state] = 'WA'
            else
              band = probable_band(chunk, index, elem)
              @show[:bands] << band if band
            end
          end
          
          @shows << @show if @show[:bands].size > 1 and @show[:venue] and @show[:date]
        end
      end
      
    end
   
    @shows.each { |s| puts s[:venue][:name] }
    @shows
  end
  
end