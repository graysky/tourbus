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
  
  def initialize(xml, url = nil)
    super
    
    # Initialize default attributes that the user can override
    @marker_text = DEFAULT_MARKER_TEXT
    @nested = false
  end
  
  # Parse out the shows  
  def parse
    #raise "You must specify table columns" if @table_columns.nil?
    
    # Find an element with the marker text
    elem = @doc.root.find_element(marker_text)
    raise "Could not find marker text" if elem.nil?
    
    # Find the table containing the text
    table = elem.find_parent("table")
    raise "Did not find parent table of elem: #{elem.to_s}" if table.nil?
    
    if @nested
      table = table.find_parent("table")
      raise "Did not find super parent table in specified nested table structure" if table.nil?
    else
      # If there is only one row in this table it's probably nested
      if table.get_elements("tr").size == 1
        @nested = true
        table = table.find_parent("table")
        raise "Did not find super parent table in calculated nested table structure" if table.nil?
      end
    end
    
    # Collect the shows
    shows = []
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
        
        puts "\n#{@show.to_yaml}"
        shows << @show
      rescue Exception => e
        # Not a valid show
        # Could us some logging here
        puts e.inspect
        puts e.backtrace
      end
      
    end
    
    shows
  end
  
  #
  # Protected
  # NOTE A lot of this will get factored down into ShowParser
  #
  protected
  
  DEFAULT_MARKER_TEXT = ['18+', '21+', 'all ages', 'a/a', '$8']
  
  # Handle a single cell
  def handle_cell(cell, index)
    types = @table_columns[index]
    return if types.nil? or types == :ignore
    
    types = [types] if !types.is_a?(Array)
  
    types.each { |type| send("parse_" + type.to_s, cell, cell.recursive_text) }
  end
  
  # Default type parsers. Sites can define their own.
  def parse_date(cell, contents)
    # The parsedate method can't handle dotted dates like 02.12.06,
    # and confuses dates with months when using dashes
    contents.gsub!(/(\.|-)/, '/')
  
    values = ParseDate.parsedate(contents, true)
    
    # Need at least a month and a date. Assume this year (for now)
    raise "Bad date: #{contents}" if values[1].nil? or values[2].nil?
    
    year = Time.now.year if values[0].nil? or values[0] != Time.now.year or values[0] != Time.now.year + 1
    date = Time.local(year, values[1], values[2])
    @show[:date] = date
  end
  
  def parse_time(cell, contents)
    
    # Break this up into multiple regexps for readability
    # With am/pm
    regexp1 = /(\d(\d)?(:\d\d)?((\s)?(am|pm)))/i
    
    # Without am/pm but WITH colon. Just a number won't do.
    regexp2 = /(\d(\d)?:\d\d)/
    
    @show[:time] = $1 if contents =~ regexp1 or contents =~ regexp2
  end
  
  # Time age and cost all jammed into one cell.
  def parse_time_age_cost(cell, contents)
    parse_time(cell, contents)
    parse_age_limit(cell, contents)
    parse_cost(cell, contents)
  end
  
  # TODO If we determine that any entries are probably not bands, but we have a least
  # one that we think is, then we should probably add the entire chunk of text as the
  # description of the show, just so no information is lost in case it's relevant and
  # it will be available in searches.
  def parse_bands(cell, contents)
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
    
    text = cell.recursive_text
    if separator == "<br>"
      # Convert to something easier to deal with
      text = HTML::strip_all_tags(raw.gsub(/<br(\/)?(\s)*>/i, "|"))
      separator = "|"
    end
    
    cell_index = 0
    text.split(separator, limit).each do |chunk|
      # TODO Lots of times parens contain the band someone is in.
      # This is useful for searches, but we don't want to create a
      # new band record... what do we do? Add to description? title?
      # TODO What about encoded chars like &amp;?
      # TODO mailto links and their content should be stripped out
      # TODO What about a band name like Damage, Inc.?
      band = probable_band(chunk, cell_index)
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
  
  # TODO This might almost always require a site-specific callback if it is not
  # the site of an individual venue.
  # Can add config options for city/state to look in if we only have a name
  def parse_venue(cell, contents)
    @show[:venue] = contents.strip
  end
  
  def parse_age_limit(cell, contents)
    @show[:age_limit] = $1 if contents.strip =~ /(18\+|21\+|all ages)/i
  end
  
  def parse_cost(cell, contents)
    @show[:cost] = $1 if contents.strip =~ /(\$\d(\d)?(\.\d\d)?)/
  end
  
  
end