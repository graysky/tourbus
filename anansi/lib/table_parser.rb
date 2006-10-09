require 'rexml/document'
require 'parsedate'
require 'yaml'
require 'anansi/lib/rexml' # TEMP
require 'anansi/lib/show_parser' # TEMP
require 'anansi/lib/string' # TEMP

# Parses show listings in a tabular form
class TableParser < ShowParser
  include REXML
  
  attr_accessor :table_columns
  attr_accessor :marker_text
  attr_accessor :nested
  attr_accessor :band_separator
  attr_accessor :use_raw_bands_text
  attr_accessor :root
  
  def initialize(xml, url = nil)
    super
    
    # Initialize default attributes that the user can override
    @marker_text = DEFAULT_MARKER_TEXT
    @nested = nil
    @use_raw_bands_text = false
  end
  
  # Parse out the shows  
  def parse    
    # Find an element with the marker text
    table = find_table
    
    if @nested
      table = table.find_parent("table")
      raise "Did not find super parent table in specified nested table structure" if table.nil?
    elsif @nested.nil?
      # If there is only one row in this table it's probably nested
      if table.get_elements("tr").size == 1
        @nested = true
        table = table.find_parent("table")
        raise "Did not find super parent table in calculated nested table structure" if table.nil?
      end
    end
    
    # Collect the shows
    table.elements.each("tr") do |row|
      path = @nested ? "td/table/tr/td" : "td"
      
      # Each cell is part of a new show
      @show = {}
      cell_index = 0 
      begin
        row.elements.each(path) do |cell|
          handle_cell(cell, cell_index)
          cell_index += 1
        end
        
        if @show[:venue].nil?
          @show[:venue] = get_venue
        end
        
        puts "\n#{@show.to_yaml}"
        @shows << @show
      rescue Exception => e
        # Not a valid show
        # Could us some logging here
        #puts e.inspect
        #puts e.backtrace
      end
    end
    
    @shows
  end
  
  def find_table
    r = @root || @doc.root
    elem = r.find_element(marker_text)
    raise "Could not find marker text" if elem.nil?
    
    # Find the table containing the text
    table = elem.find_parent("table")
    raise "Did not find parent table of elem: #{elem.to_s}" if table.nil?
   
    table
  end
  
  #
  # Protected
  # NOTE A lot of this will get factored down into ShowParser
  #
  protected
  
  DEFAULT_MARKER_TEXT = ['18+', '21+', 'all ages', 'a/a', '$8', '$5', '$10', 
                         '$15', '$12', '$7', 'All Ages', 'ALL AGES']
  
  # Handle a single cell
  def handle_cell(cell, index)
    types = @table_columns[index]
    return if types.nil? or types == :ignore
    
    types = [types] if !types.is_a?(Array)
  
    types.each { |type| send("parse_" + type.to_s, cell, cell.recursive_text) }
  end
  
  # Default type parsers. Sites can define their own.
  def parse_date(cell, contents)
    @show[:date] = parse_as_date(contents)
  end
  
  def parse_time(cell, contents)
    @show[:time] = parse_as_time(contents)
  end
  
  # Time age and cost all jammed into one cell.
  def parse_time_age_cost(cell, contents)
    parse_time(cell, contents)
    parse_age_limit(cell, contents)
    parse_cost(cell, contents)
  end
  
  # To be overriden
  def preprocess_bands_text(text)
    text
  end
  
  # TODO If we determine that any entries are probably not bands, but we have a least
  # one that we think is, then we should probably add the entire chunk of text as the
  # description of the show, just so no information is lost in case it's relevant and
  # it will be available in searches.
  def parse_bands(cell, contents)
    before_parse_bands(cell, contents)
    
    bands = []
    # First try to figure out the separator.
    raw = cell.to_s
    
    limit = 0 # Unlimited chunks returned from split
    separator = @band_separator
    if separator.nil?
      if raw.downcase.include?("<br>") or raw.downcase.include?("<br/>")
        separator = "<br>" 
      elsif raw.include?(",")
        separator = ","
      else
        # Don't split at all...
        limit = 1
      end
    end
    
    text = @use_raw_bands_text ? raw : cell.recursive_text
    if separator == "<br>"
      # Convert to something easier to deal with
      text = HTML::strip_all_tags(raw.gsub(/<br(\/)?(\s)*>/i, "|"))
      separator = "|"
    end
    
    text = preprocess_bands_text(text)
    
    cell_index = 0
    # Ignore the separator if it's in parens.
    text.gsub!(Regexp.new("(\\(.*)#{separator}(.*\\))"), "\\1 \\2")
    text.split(separator, limit).each do |chunk|
      band = probable_band(chunk, cell_index, cell)
      
      if band
        bands << band
      else
        puts "**** Not a band: #{chunk}"
      end
      
      cell_index += 1
    end
    
    raise "No bands" if bands.empty?
    
    @show[:bands] = bands
  end
  
  # To be overriden by sites
  # TODO Make a generic thing
  def before_parse_bands(cell, contents)
  
  end
  
  # TODO This might almost always require a site-specific callback if it is not
  # the site of an individual venue.
  # Can add config options for city/state to look in if we only have a name
  def parse_venue(cell, contents)
    @show[:venue] ||= get_venue
    @show[:venue][:name] = contents.strip
  end
  
  def parse_venue_name(cell, contents)
    @show[:venue] ||= get_venue
    @show[:venue][:name] = contents.strip
  end
  
  def parse_venue_location(cell, contents)
    @show[:venue] ||= get_venue
    chunks = contents.strip.split(',')
    @show[:venue][:city] = chunks[0].strip
    @show[:venue][:state] = chunks[1].strip if chunks.size > 1
  end
  
  def parse_age_limit(cell, contents)
    @show[:age_limit] = parse_as_age_limit(contents)
  end
  
  def parse_cost(cell, contents)
    @show[:cost] = parse_as_cost(contents)
  end
  
  def parse_description(cell, contents)
    @show[:description] = contents
  end
  
end