require 'net/http'

# Given a starting url, finds a set of urls to be processed later.
class UrlFinder
  attr_reader :start
  
  def initialize(start)
    @start = start
  end
  
  # Return an array of urls, starting at the starting page
  # To be extended by subclasses.
  def find_urls
    []
  end
  
end