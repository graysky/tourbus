require 'rexml/document'
require 'parsedate'
require 'yaml'
require 'anansi/lib/rexml' # TEMP
require 'anansi/lib/show_parser' # TEMP
require 'anansi/lib/string' # TEMP

# ULGY parser for the mideast.
class TTsParser < ShowParser
  include REXML
  
  def parse
    @doc.root.each_element("//div") do |div|
      begin
        if div.attribute('class').to_s == 'MONTH_NUMBER'
          @show = {}
          @show[:bands] = []
          month = div.recursive_text.to_i
               
          show_div = div.next_element
          show_div.each_element do |elem|
            if elem.name == 'span' and elem.attribute('class').to_s == 'PERF_NAME'
              band = {}
              band[:name] = elem.recursive_text.strip
              elem.each_element('a') do |a| 
                band[:url] = a.attribute('href').to_s.strip
              end
              
              @show[:bands] << band
            end
          end
          
          next if @show[:bands].empty?
        
          @show[:venue] = {}
          @show[:venue][:name] = "T.T. The Bear's"
          
          puts "Show is #{@show.to_yaml}\n\n"
          @shows << @show
        end
      rescue Exception => e
        puts e
        puts e.backtrace
      end
    end
    
    @shows
  end
  
  def default_time
    "9pm"
  end
end