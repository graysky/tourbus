require 'rexml/document'
require 'rexml/streamlistener'

class ItunesListener
  include REXML
  include StreamListener
  
  attr_reader :bands
 
  def initialize
    @bands = []
  end
  
  def text(text)
    if @next_is_band
      bands << text
      @next_is_band = false
    else      
      @next_is_band = true if text == 'Artist'
    end
  end
  
end

class Itunes
  include REXML
   
  MAX_SIZE = 2 * 1024 * 1024 # 2MB
  MAX_SONGS = 1000
  
  def self.get_bands_from_playlist(xml)
    listener = ItunesListener.new
    parser = Parsers::StreamParser.new(xml, listener)
    parser.parse
    
    raise "There are more than #{MAX_SONGS} songs in the file" if listener.bands.size > MAX_SONGS
    return listener.bands.uniq
  end
  
end