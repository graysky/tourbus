require 'rubygems'
require 'html/xmltree'
require 'net/http'
require 'rexml/document'
require 'anansi/lib/rexml'
require 'anansi/lib/html'
require 'lib/string_helper'
require 'parsedate'
require 'open-uri'
require "yaml/store"
require 'CGI'

# VERY quick and dirty

include REXML
$venue_hashes = []
def yahoo(addr)
      return nil if addr.nil? || addr.strip == ""
      base_url = "http://api.local.yahoo.com/MapsService/V1/geocode?appid=tourb.us&location="
      url = base_url + CGI.escape(addr)
      p url
      
      response = open(url)
      doc = Document.new(response.read)

      
      return nil if doc.root.elements.size != 1
  
      value = {}          
      doc.root.each_element("//Result") do |elem|
        value[:precision] = elem.attributes["precision"]
        value[:city] = elem.elements["City"].text
        value[:state] = elem.elements["State"].text
        value[:latitude] = elem.elements["Latitude"].text
        value[:longitude] = elem.elements["Longitude"].text
        
        # Get regular 5-digit zip
        zip = elem.elements["Zip"].text
        if not zip.nil?
          zip = zip[0, zip.index("-")] if zip.index("-")  
        end
        value[:zipcode] = zip
        
        # Get the address with normal capitalization
        if elem.elements["Address"].text
          value[:address] = elem.elements["Address"].text.split(" ").each { |s| s.capitalize! }.join(" ")
        end
      end
      
      return value
    end

begin
for i in (1..49)
  puts "Get page #{i}"
  Net::HTTP.start("listings.sfweekly.com", 80) do |http|
    response = http.get("/gyrobase/Music/VenueGuide?page=" + i.to_s)
    parser = HTMLTree::XMLParser.new(false, false)
    puts "Parse body"
    parser.feed(response.body)
    
    doc = parser.document
    doc.root.each_element("//div[@class='eventtitle1']") do |elem|
      name = elem.recursive_text.strip
      b = elem.next_sibling.next_sibling.next_sibling.next_sibling
      a = nil
      for j in (0..b.children.size)
        next if not b.children[j].respond_to?(:name)
        if b.children[j].name == "b"
          a = b.children[j]
          break
        end
      end
      
      
      brs = 0
      addr = ""
      city = ""
      phone = ""
      url = ""
      for j in (0..a.children.size)
        str = a.children[j].to_s.strip
        #puts "str is #{str}"
        if str == "<br/>" or str == "<br>"
          brs += 1
          next
        end
        
        addr += " " + str if brs == 0
        city += " " + str if brs == 1
        phone = str if brs == 2
        if brs == 3
          url = a.children[j].recursive_text
          break
        end
        
      end
      
      addr = addr.gsub(/\((.)*\)/, '')
      addr = addr.gsub(/&amp;/, '&')
      addr.strip!
      city = city.gsub(/\((.)*\)/, '')
      city.strip!
      phone.strip!
      url.strip!
      
      data = yahoo("#{addr}, #{city}, CA")
      puts data.inspect
      if data [:precision] == "address"
        $venue_hashes << {"name" => name, "url" => url, "phone" => phone, "address" => data[:address],
                       "state" => data[:state], "zip" => data[:zipcode], "city" => data[:city],
                       "latitude" => data[:latitude], "longitude" => data[:longitude]}
      else
        puts "!skip venue: #{name}, #{addr}"
      end
    end
  end
end
rescue Exception => e
  puts "ERROR " + e.inspect
  puts e.backtrace
end
#html = File.new('script/sf_venues.html').read
#html = HTML::strip_tags(html)

y = YAML::Store.new("sf_venues2.yaml", :Indent => 2)
  y.transaction do
    y['venues'] = $venue_hashes
  end   
#parser = HTMLTree::XMLParser.new(false, false)
#parser.feed(html)

# Get rexml doc
#doc = parser.document
