# Schema as of Sun Feb 18 18:07:46 Eastern Standard Time 2007 (schema version 43)
#
#  id                  :integer(11)   not null
#  band_id             :integer(11)   
#  artist              :string(255)   
#  title               :string(255)   
#  song_site_id        :integer(11)   
#  status              :integer(11)   default(0)
#  album               :string(255)   
#  year                :string(255)   
#  url                 :string(255)   
#  size                :integer(11)   
#  created_at          :datetime      
#  checked_at          :datetime      
#

class Song < ActiveRecord::Base
  belongs_to :band
  belongs_to :song_site
  
  STATUS_OK = 0
  STATUS_MISSING = 1
  STATUS_REMOVED = 2
  STATUS_UNKNOWN = 3
  
  # song is a hash of song attributes, matching song column names
  def self.from_hash(song, site)
    # check for dupes
    return if self.find_by_artist_and_title(song['artist'], song['title'])
    band = Band.find_by_short_name(Band.name_to_id(song['artist']))
    
    s = Song.new
    s.status = STATUS_OK
    s.band = band || nil
    s.song_site = site
    s.artist = song['artist']
    s.title = song['title']
    s.year = song['year']
    s.album = song['album']
    s.url = song['url']
    s.size = song['size']
    s.checked_at = Time.now
    
    s.save!
  end
end
