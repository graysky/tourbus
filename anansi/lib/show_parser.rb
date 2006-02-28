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
  
  # Returns an array of the prepared band name and the extra content
  def prepare_band_name(name)
    # Remove ampersand if it begins with it
    name.gsub!(/&/, '') if name[0..0] == "&"
    name.gsub!(/&amp;/, '') if name[0..4] == "&amp;"
    
    extra = nil
    
    # Remove parts in parens
    name = name.gsub(/(\((.)*\))/, '')
    extra = $1 if not $1.nil?
    
    # Remove parts in brackets
    name = name.gsub(/(\[(.)*\])/, '')
    extra = $1 if not $1.nil?
    
    # Remove everything after a dash if there is whitespace around it.
    index = name.index(" - ")
    extra = name[index, name.length] if index
    name = name[0, index] if index
    
    extra.strip! if not extra.nil?
    [name.strip, extra]
  end
  
  # Index is there because certain phrases are more likely to mean there is not a band playing
  # TODO We need a config option so that sites can override this. People do wacky things with band listings!
  def probable_band(name, index, starting_preamble = nil)
    return nil if name.nil? or name.strip == ""
    
    name, extra = prepare_band_name(name)
    preamble = nil
    
    if index == 0
      name, preamble = process_first_band(name)
      return nil if name.nil?
    end
    
    down = name.downcase
    
    return nil if down.ends_with?(":")
    return nil if down.include?("tba") or down.include?("t.b.a") # Too restrictive? Not many words with tba.
    return nil if down.split(" ").size > 10 # more like a paragraph than a band name
    return nil if down.ends_with?("and more...") or down.ends_with?("and more") or down.ends_with?("more...")
    return nil if down.include?("special guest")
    return nil if down.include?("many more")
    return nil if down.include?("+")
    
    band = {}
    band[:name] = name
    band[:extra] = extra if extra
    band[:preamble] = preamble if preamble
    
    band
  end
  
  def process_first_band(name, preamble = nil)
    down = name.downcase
    
    # The first one is tricky because it could have some preamble that
    # we need to strip off and save, and still get the headlining band.
    # But first, if we end with these strings than this entire first chunk
    # is just a preamble. TODO We should probably save it
    return nil if down.ends_with?(" with")
    return nil if down.ends_with?("presents")
    return nil if down.ends_with?("present")
    return nil if down.ends_with?("featuring")
    return nil if down.ends_with?("special guest")
    return nil if down.ends_with?(":")
    
    keywords = [":", "featuring", "presents", "presenting", "special guest"]
    index = first_index_in(keywords, down)
    if index
      new_preamble = name[0..index].strip
      new_preamble = preamble + ' ' + new_preamble if preamble
      name = name[index, name.length]
      name, preamble = process_first_band(name, new_preamble)
    end
    
    return name.strip, preamble.nil? ? nil : preamble.strip
  end
  
  # Parse the given string as a date
  def parse_as_date(str, raise_on_error = true)
    # The parsedate method can't handle dotted dates like 02.12.06,
    # and confuses dates with months when using dashes
    str.gsub!(/(\.|-)/, '/')
  
    values = ParseDate.parsedate(str, true)
    
    # Need at least a month and a date. Assume this year (for now)
    if values[1].nil? or values[2].nil?
      raise "Bad date: #{str}" if raise_on_error
      return nil
    end
    
    year = Time.now.year if values[0].nil? or values[0] != Time.now.year or values[0] != Time.now.year + 1
    Time.local(year, values[1], values[2])
  end
  
  # Get the metaclass for this object
  def metaclass
    class << self; self; end
  end
  
  private
  
  # Return the index of the first choice that is found in str
  # plus the length of the string
  def first_index_in(choices, str)
    choices.each do |choice|
      index = str.index(choice)
      return index + choice.length if index
    end
    
    nil
  end
  
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