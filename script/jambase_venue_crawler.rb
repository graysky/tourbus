require 'config/environment'
require 'yaml'
require 'net/http'
require 'uri'
require 'rexml/document'
require 'html/xmltree'
require 'anansi/lib/html'

include REXML

file = "anansi/data/jambase_ny/parse/jambase_ny0.yml"
base = "http://www.jambase.com/"

shows = YAML::load(File.open(file))

venues = {}

for show in shows
  venue = venues[show[:venue][:name]]
  next if venue
  
  venue = {}
  venues[show[:venue][:name]] = venue

  url = base + show[:venue][:detail_link]
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  
  resp = http.get(uri.request_uri)
  
  # Would be nice to factor all of this out... do it once we have more than 2 uses
  html = resp.body
  
  html.gsub!(/&nbsp;/, ' ') unless @leave_nbsps # TODO Needed?
  
  # Delete comments, including misformatted ones
  html.gsub!(/<!(.*)->/, '')
  html.gsub!(/<!doctype(.*)>/, '')
  # Form action URL was breaking loganjealous with str like: action="/?p=subscribe&#038;id=1"
  html.gsub!(/\#038/, '')
  
  parser = HTMLTree::XMLParser.new(false, false)
  parser.feed(html)
  
  # Get REXML doc
  doc = parser.document
  
  title = XPath.first(doc, "//title")
  content = title.text.split("|")
  next unless content[1] && content[2]
  venue[:name] = content[1].strip
  venue[:city_state] = content[2].strip
  
  span = XPath.first(doc, "//span[@class='titleText']")
  if span.nil?
    puts "No titleText? " + url
    next
  end
  
  content = span.text.split("::")
  if content && content[1]
    venue[:address] = content[1].strip
  else
    next
  end
  
  link = XPath.first(doc, "//a[@target='venue']")
  if link
    venue[:url] = link.attributes["href"]
  end
  
  # geocode the url
  begin
    addr = venue[:address] + ", " + venue[:city_state]
    result = Geocoder.yahoo(addr)
    if result && result[:precision] == "address"
      venue[:latitude] = result[:latitude]
      venue[:longitude] = result[:longitude]
      venue[:city] = result[:city]
      venue[:address] = result[:address]
      venue[:state] = result[:state]
      venue[:zipcode] = result[:zipcode]
    end
  rescue Exception => e
    p e
    next
  end
  
  p venue
end

yml_file = File.new("venues.yml", "w")        
yml_file.write(venues.to_yaml)