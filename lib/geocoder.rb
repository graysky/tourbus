require "xmlrpc/client"
#require 'CGI'
require 'open-uri'
require "rexml/document"

# Yahoo documentation:
# http://developer.yahoo.net/maps/rest/V1/geocode.html
class Geocoder
  include REXML
  
  @@base_url = "http://api.local.yahoo.com/MapsService/V1/geocode?appid=tourb.us&location="
  
    def self.yahoo(addr)
      return nil if addr.nil? || addr.strip == ""
      
      url = @@base_url + CGI.escape(addr)
      
      begin
        response = open(url)
        doc = Document.new(response.read)
      rescue => e
        RAILS_DEFAULT_LOGGER.error("Error getting geocoding: #{url}, #{e.to_s}")
        return nil
      end

      
      return nil if doc.root.elements.size != 1
  
      value = {}          
      doc.root.each_element("//Result") do |elem|
        value[:precision] = elem.attributes["precision"]
        value[:city] = elem.elements["City"].text.capitalize
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

  def self.geocode(addr)
    server = XMLRPC::Client.new2("http://rpc.geocoder.us/service/xmlrpc")
    result = server.call2("geocode", addr)
    
    # First element of array is boolean for fault/no fault
    # Second element is the actual respose or fault object
    # TODO: Beef up error handling, exceptions, etc
    if (!result or !result[0] or !result[1][0] or !result[1][0]["long"])
      return nil  
    end
    
    return result[1][0]
  end
end