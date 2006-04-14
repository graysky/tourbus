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
  
  def self.get_bands_from_playlist(xml)
    listener = ItunesListener.new
    parser = Parsers::StreamParser.new(xml, listener)
    parser.parse
    
    return listener.bands.uniq
  end
  
end