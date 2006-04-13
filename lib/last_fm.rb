require 'open-uri'
require "rexml/document"

class LastFm
  include REXML
  
  def self.top_50_bands(username)
    url = "http://ws.audioscrobbler.com/1.0/user/#{username}/topartists.xml"
    
    response = open(url)
    doc = Document.new(response.read)
    
    bands = []
    doc.each_element("//name") do |elem|
      bands << elem.text
    end
    
    return bands
  end
end