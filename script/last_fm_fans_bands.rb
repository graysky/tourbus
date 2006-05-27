require 'open-uri'
require 'uuidtools'
require 'rexml/document'
require 'uuidtools'
require 'config/environment'

include REXML

def make_call(url)
  sleep(1)
  response = open(url)
  Document.new(response.read)
end


tags = ['indie', 'seen+live', 'metal', 'punk']

tags.each do |tag|
  p tag
  doc = make_call("http://ws.audioscrobbler.com/1.0/tag/#{tag}/topartists.xml")
  
  doc.each_element("//artist") do |elem|
    name = elem.attribute('name').to_s
    p "Found band: #{name}"
    id = Band.name_to_id(name)
    band = Band.find_by_short_name(id)
    if band.nil?
      p "   Create new"
      band = Band.new_band(name)
      band.save!
    end
    
    # get fans
    url_name = name.gsub(' ', '+')
    fans_doc = make_call("http://ws.audioscrobbler.com/1.0/artist/#{url_name}/fans.xml")
    
    fans_doc.each_element("//user") do |elem|
      username = elem.attribute('username').to_s
      p "     Found fan: #{username}"
      uid = Band.name_to_id(username)
      fan = Fan.find_by_name(uid)
      if fan.nil?
        p "      create new"
        fan = Fan.create_test_fan(uid)
        fan.save!
      end
      
      
      begin 
        # Get faves
        faves_doc = make_call("http://ws.audioscrobbler.com/1.0/user/#{username}/topartists.xml")
        faves_doc.each_element("//name") do |elem|
          name = elem.text
          next if name == "!!!"
          p "Found band: #{name}"
          id = Band.name_to_id(name)
          band = Band.find_by_short_name(id)
          if band.nil?
            p "   Create new"
            band = Band.new_band(name)
            band.save!
          end
          
          fan.add_favorite(band)
          
          # Get related bands
          url_name = name.gsub(' ', '+')
          related_doc = make_call("http://ws.audioscrobbler.com/1.0/artist/#{url_name}/similar.xml")
          related_doc.each_element("//name") do |elem|
            name = elem.text
            next if name == "!!!"
            p "  Found band: #{name}"
            id = Band.name_to_id(name)
            other = Band.find_by_short_name(id)
            if other.nil?
              p "   Create new"
              other = Band.new_band(name)
              other.save!
            end
          
            puts "** Relate two bands: #{band.name}, #{other.name}"
            band.add_related_band(other)
          end
          
        end
      rescue => e
      
      end
      
      fan.save!
      
    end
    
  end
  
end
