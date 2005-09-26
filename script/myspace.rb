require 'net/http'

# Just testing...
Net::HTTP.start("www.myspace.com", 80) do |http|
  response = http.get("/")
  p response.body
  cookie = response["set-cookie"]
  puts "After initial get: #{cookie}"
  
  data = [
        "email=thebloodfeathers@gmail.com",
        "password=mytourb.us"
      ].join("&")
  
  response = http.post("/index.cfm?fuseaction=login.process", data)    
  p response.body
  cookie = response["set-cookie"]
  puts "\n\n\n\n\nAfter login: #{cookie}"
end
