require "yaml/store"
require 'net/http'
require "xmlrpc/client"

$venue_hashes = []

def self.geocode(addr)
  server = XMLRPC::Client.new2("http://rpc.geocoder.us/service/xmlrpc")
  result = server.call2("geocode", addr)
  
  # First element of array is boolean for fault/no fault
  # Second element is the actual respose or fault object
  p addr
  if (!result or !result[0] or !result[1][0] or !result[1][0]["long"])
    return nil  
  end
  
  return result[1][0]
end

def self.parse_page_contents(contents)
  contents =~ /<p>(.*?)<br>/
  name = $1
  
  if (contents =~ /(\d\d\d-\d\d\d-\d\d\d\d)/)
    phone = $1
  end
  
  index = contents.rindex("<strong")
  if (index)
    index 
    contents = contents[index..-1]
  end
  
  contents =~ /\n(.*?)<br \/>\n(.*?)\n/
  address = $1
  city, state = $2.split(",").each { |item| item.strip! }

  contents =~ /<a target='_blank' href=(.*?)>/
  url = $1

  if (!address.nil? and address != "")
    full_address = "#{address}, #{city} #{state}"
    data = geocode(full_address)
    if (data)
      zip = "0" + data["zip"].to_s
    
      $venue_hashes << {"name" => name, "url" => url, "phone" => phone, "address" => address,
                       "state" => data["state"], "zip" => zip, "city" => data["city"],
                       "latitude" => data["lat"], "longitude" => data["long"]}  
                       
      puts "FOUND: ", name,phone,address + ", " + city + ", " + state,url                 
    else
      puts "DID NOT FIND: ", name,phone,address + ", " + city + ", " + state,url
    end
  end
  
end

for i in (201..2020)
  puts "\nGet page #{i}\n"
  Net::HTTP.start("www.punkdates.com", 80) do |http|
    response = http.get("/view.php?id=#{i}")
    parse_page_contents(response.body)
  end
  
  if (i % 50 == 0)
    y = YAML::Store.new("punk_venues#{i}.yaml", :Indent => 2)
    y.transaction do
      y['venues'] = $venue_hashes
    end
  end   
end