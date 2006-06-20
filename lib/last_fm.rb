require 'open-uri'
require "rexml/document"

class LastFm
  include REXML
  
  # Return the top 50 bands for this last.fm user
  # If the user name doesn't exist, or last.fm can't be reached, return nil
  def self.top_50_bands(username)
    url = "http://ws.audioscrobbler.com/1.0/user/#{username}/topartists.xml"
    
    begin
      response = open(url)
      doc = Document.new(response.read)
    rescue OpenURI::HTTPError => e
      puts "Error reading top 50 for last.fm user #{username}, #{e.to_s}"
      # We can't recover
      return nil
    end
    
    bands = []
    doc.each_element("//name") do |elem|
      bands << elem.text
    end
    
    return bands
  end
end