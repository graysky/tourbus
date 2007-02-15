require 'open-uri'
require "rexml/document"

class LastFm
  include REXML
  
  # Return the top 50 bands for this last.fm user
  # If the user name doesn't exist, or last.fm can't be reached, return nil
  def self.top_50_bands(username)
    url = "http://ws.audioscrobbler.com/1.0/user/#{CGI::escape(username)}/topartists.xml"
    
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

  # Return the top bands for this week's listening  
  def self.top_weekly_bands(username)
    url = "http://ws.audioscrobbler.com/1.0/user/#{CGI::escape(username)}/weeklyartistchart.xml"
    
    begin
      response = open(url)
      doc = Document.new(response.read)
    rescue OpenURI::HTTPError => e
      puts "Error reading top weekly bands for last.fm user #{username}, #{e.to_s}"
      # We can't recover
      return nil
    end
    
    bands = []
    #puts "Document: #{doc.root}"
    doc.root.each_element("//artist") do |artist|
      band_name = nil
      
      artist.each_element("name") do |elem|
        band_name = elem.text
      end
      
      # Only add artists with >=3 plays
      artist.each_element("playcount") do |playcount|
        count = playcount.text.to_i
        if count > 2
          bands << band_name
        end
      end
    end
    
    return bands
  end
  
end