require 'rexml/document'
require 'parsedate'
require 'yaml'
require 'anansi/lib/rexml' # TEMP
require 'anansi/lib/show_parser' # TEMP
require 'anansi/lib/string' # TEMP

# ULGY parser for the mideast.
class TTsParser < ShowParser
  include REXML
  
  attr_accessor :month
  attr_accessor :year
  
  def parse
    @doc.root.each_element("//div") do |div|
      begin
        if div.attribute('class').to_s == 'MONTH_NUMBER'
          @show = {}
          @show[:bands] = []
          
          index = 0
          show_div = div.next_element
          show_div.each_element do |elem|
            if elem.name == 'span' and elem.attribute('class').to_s == 'PERF_NAME'
              band = {}
              band = probable_band(elem.recursive_text.strip, index, elem)
              
              if band
                elem.each_element('a') do |a| 
                  band[:url] = a.attribute('href').to_s.strip
                end
                
                @show[:bands] << band
              end
               
              index += 1
            end
          end
          
          next if @show[:bands].empty?
          
          day = div.recursive_text.to_i
          @show[:date] = Time.local(@year, @month, day)
          @show[:time] = default_time     
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