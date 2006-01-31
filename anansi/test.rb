require 'tidy'
require 'net/http'
require 'rexml/document'
include REXML

# Point ruby at the tidy dll
Tidy.path = 'c:\\dev\\tidy\\bin\\tidy.dll'

url = 'www.greatscottboston.com'
html = ''

# Get nasty, nasty page contents
Net::HTTP.start(url, 80) do |http|
  response = http.get("/main.cgi")
  html = response.body
end

# Parse and convert to xml
xml = Tidy.open(:show_warnings => true) do |tidy|
  tidy.options.output_xml = true
  tidy.clean(html)
end

# Get rexml doc
doc = Document.new(xml)

puts doc.to_s