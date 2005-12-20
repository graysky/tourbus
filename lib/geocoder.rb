require "xmlrpc/client"

# TODO The yahoo api is much better, we should rewrite using that.
class Geocoder
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