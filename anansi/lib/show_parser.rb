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
  
  # Set the site for this parser
  def site=(site)
    @site = site
    
    # Pull in the overridden methods from the site
    import_site_methods
  end
  
  # Parse the document and return a YAML document with the show info
  def parse
    raise "Implement this method in the subclass"
  end
  
  def prepare_band_name(name)
    # Remove ampersand if it begins with it
    name.gsub(/&/, '') if name[0..0] == "&"
    name.gsub(/&amp;/, '') if name[0..4] == "&amp;"
    
    # Remove parts in parens
    name = name.gsub(/\((.)*\)/, '')
    
    # Remove parts in brackets
    name = name.gsub(/\[(.)*\]/, '')
    
    # Remove everything after a dash if there is whitespace around it.
    index = name.index(" - ")
    name = name[0, index] if index
    
    name.strip
  end
  
  # Index is there because certain phrases are more likely to mean there is not a band playing
  # TODO We need a config option so that sites can override this. People do wacky things with band listings!
  def probable_band(name, index, extra = nil)
    downcase = name.downcase
    return nil if name.nil? or name.strip == ""
    
    name = prepare_band_name(name)
    
    # This list will grow a lot over time... this is very basic.
    # Not all of these will necessarily apply to non-table layouts. Will need to figure out
    # how to handle all the different cases.
    # TODO take everything AFTER : or present or with ALSO DO "Featuring"
    return nil if index == 0 and downcase.include?(":")
    return nil if index == 0 and downcase.ends_with?("presents")
    return nil if index == 0 and downcase.ends_with?(" with")
    return nil if name.ends_with?(":")
    return nil if downcase.include?("tba") or downcase.include?("t.b.a") # Too restrictive? Not many words with tba.
    return nil if name.split(" ").size > 12 # more like a paragraph than a band name
    return nil if downcase.ends_with?("and more...") or downcase.ends_with?("and more") or downcase.ends_with?("more...")
    return nil if downcase.include?("special guest")
    return nil if downcase.include?("+")
    
    return name
  end
  
  # Get the metaclass for this object
  def metaclass
    class << self; self; end
  end
  
  private
  
  # Define a new method on this object
  def define_method(name, &block)
    metaclass.send(:define_method, name, &block)
  end
  
  # Pull in the overriden methods from the site object
  def import_site_methods
    
    # For each method the site overrides, pull out:
    # name => the name of the method
    # value => array of the proc and num of arguments it takes
    @site.methods.each do |name, value|
      
      # Define the new method on this parser
      @site.create_method(self, name, value)
    end
  end
  
end