require 'rexml/document'
require 'parsedate'
require 'yaml'
require 'anansi/lib/rexml' # TEMP
require 'anansi/lib/show_parser' # TEMP
require 'anansi/lib/string' # TEMP

class PAsParser < ShowParser
  include REXML
  
  attr_accessor :month
  attr_accessor :year
  
  def parse
    @doc.root.each_element("//span") do |span|
      begin
        if span.attribute('class').to_s == 'subhead_red'
          day = span.recursive_text
          next if day.to_i == 0
          
          @show = {}
          @show[:bands] = []
          
          row = span.find_parent("tr").next_element.next_element
          index = 0
          row.elements[1].each_element("p") do |p|
            next if p.elements[1] and p.elements[1].name == "em"
            
            name = p.recursive_text.strip
            band = probable_band(name, index, p)
            @show[:bands] << band if band
            index += 1
          end
          
          next if @show[:bands].empty?
          
          @show[:date] = Time.local(@year, @month, day)
          @show[:time] = default_time     
          @show[:venue] = { :name => "PA's Lounge"}
          
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