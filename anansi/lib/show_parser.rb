require 'rexml/document'
require 'anansi/lib/html' # temp

# Base class for all show parsers
class ShowParser
  include REXML
  
  # Create a new parser for the given chunk of xml or rexml document
  def initialize(xml, url = nil)
    @doc = xml.is_a?(String) ? Document.new(HTML::strip_tags(xml)) : xml
    @url = url
    
    @show = nil # The current show being processed
  end
  
  # Parse the document and return a YAML document with the show info
  def parse
    raise "Implement this method in the subclass"
  end
  
  def prepare_band_name(name)
    # Remove parts in parens
    name = name.gsub(/\((.)*\)/, '')
    
    # Remove parts in brackets
    name = name.gsub(/\[(.)*\]/, '')
    
    # Remove everything after a dash if there is whitespace around it.
    index = name.index(" - ")
    name = name[0, index] if index
    
    name.strip
  end
  
  # TODO This should use our database and myspace, as well
  # Index is there because certain phrases are more likely to mean there is not a band playing
  # TODO We need a config option so that sites can override this. People do wacky things with band listings!
  def probable_band?(name, index)
    downcase = name.downcase
    
    # This list will grow a lot over time... this is very basic.
    # Not all of these will necessarily apply to non-table layouts. Will need to figure out
    # how to handle all the different cases.
    return false if name.nil? or name.strip == ""
    return false if name.ends_with?(":")
    return false if index == 0 and downcase.include?(":")
    return false if index == 0 and downcase.ends_with?("presents")
    return false if downcase.include?("tba") # Too restrictive? Not many words with tba.
    return false if name.split(" ").size > 12 # more like a paragraph than a band name
    return false if downcase.ends_with?("and more...") or downcase.ends_with?("and more") or downcase.ends_with?("more...")
    return false if index == 0 and downcase.ends_with?(" with")
    return false if downcase.include?("special guest")
    return false if downcase.include?("+")
    
    return true
  end
  
  
end
