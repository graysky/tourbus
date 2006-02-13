require 'rubygems'
require 'html/xmltree'
require 'net/http'
require 'rexml/document'
require 'anansi/rexml'
require 'anansi/html'
require 'lib/string_helper'
require 'parsedate'
include REXML

class String
  def ends_with?(suffix)
    suffix = suffix.to_s
    self[-suffix.length, suffix.length] == suffix      
  end
end

def table_columns
  { 0 => :date, 1 => :time, 2 => :bands, 
    3 => :venue, 4 => :age_limit, 5 => :cost, 6 => :ignore }
end

def handle_cell(index, cell, show)
  type = table_columns[index]
  return if type.nil? or type == :ignore
  
  send("parse_" + type.to_s, cell, show)  
end

def parse_date(cell, show)
  contents = cell.recursive_text
  
  # The parsedate method can't handle dotted dates like 02.12.06,
  # and confuses dates with months when using dashes
  contents.gsub!(/(\.|-)/, '/')

  values = ParseDate.parsedate(contents, true)
  
  # Need at least a month and a date. Assume this year (for now)
  raise "Bad date: #{contents}" if values[1].nil? or values[2].nil?
  
  year = values[0] || Time.now.year
  date = Time.local(year, values[1], values[2])
  show[:date] = date
end

def parse_time(cell, show)
  # Try to parse the time straight
  contents = cell.recursive_text
  values = ParseDate.parsedate(contents)
  
  if (values[3].nil? or values[4].nil?) and not contents.include?(":")
    # It might be something like "7pm"
    contents = contents.gsub(/(\d+)\s*(pm|PM|am|AM)/) { |match| $1 + ":00" + $2 }
    values = ParseDate.parsedate(contents)
  end
  
  if values[3].nil? or values[4].nil?
    show[:time] = ''
  else
    show[:time] = contents.strip
  end
end

# TODO This should use our database and myspace, as well
# Index is there because certain phrases are more likely to mean there is not a band playing
# TODO We need a config option so that sites can override this. People do wacky things with band listings!
def probable_band?(name, index)
  downcase = name.downcase
  
  # This list will grow a lot over time... this is very basic.
  # Not all of these will necessarily apply to non-table layouts. Will need to figure out
  # how to handle all the different cases.
  return false if name.ends_with?(":")
  return false if index == 0 and downcase.include?(":")
  return false if index == 0 and downcase.ends_with?("presents")
  return false if downcase.include?("tba") # Too restrictive? Not many words with tba.
  return false if name.split(" ").size > 12 # more like a paragraph than a band name
  return false if downcase.ends_with?("and more...") or downcase.ends_with?("and more") or downcase.ends_with?("more...")
  return false if index == 0 and downcase.ends_with?(" with")
  
  return true
end

# TODO If we determine that any entries are probably not bands, but we have a least
# one that we think is, then we should probably add the entire chunk of text as the
# description of the show, just so no information is lost in case it's relevant and
# it will be available in searches.
def parse_bands(cell, show)
  bands = []
  # First try to figure out the separator.
  raw = cell.to_s
  
  if raw.downcase.include?("<br>") or raw.downcase.include?("<br/>")
    # The band are probably separately by <br> tags
    processed = HTML::strip_all_tags(raw.gsub(/<br(\/)?(\s)*>/i, "|"))
    # FINISH
  elsif raw.include?(",")
    # Try going by comma
    cell_index = 0
    cell.recursive_text.split(",").each do |chunk|
      # TODO Lots of times parens contain the band someone is in.
      # This is useful for searches, but we don't want to create a
      # new band record... what do we do? Add to description? title?
      # TODO What about encoded chars like &amp;?
      # TODO mailto links and their content should be stripped out
      # TODO What about a band name like Damage, Inc.?
      
      # Remove parts in parents
      chunk = chunk.gsub(/\((.)*\)/, '')
      
      # Remove parts in brackets
      chunk = chunk.gsub(/\[(.)*\]/, '')
      
      # Dashes shouldn't appear in band names. Remove everything after a dash.
      index = chunk.index("-")
      chunk = chunk[0, index] if index
      
      chunk.strip!
      if probable_band?(chunk, cell_index)
        bands << chunk 
      else
        puts "**** Not a band: #{chunk}"
      end
      
      cell_index += 1
    end
  else
    # TODO Maybe just one band
  end
  
  raise "No bands" if bands.empty?
  
  show[:bands] = bands
end

# TODO This might almost always require a site-specific callback if it is not
# the site of an individual venue.
# Can add config options for city/state to look in if we only have a name
def parse_venue(cell, show)
  show[:venue] = cell.recursive_text.strip
end

# TODO
def parse_age_limit(cell, show)
  show[:age_limit] = cell.recursive_text.strip
end

# TODO
def parse_cost(cell, show)
  show[:cost] = cell.recursive_text.strip
end


#################
# Main
#################
html = File.new('anansi/ohmyrockness.test.html').read
html = HTML::strip_tags(html)

parser = HTMLTree::XMLParser.new(false, false)
parser.feed(html)

#html = File.new('anansi/lotsofnoise.test.html').read


# Get rexml doc
doc = parser.document

# Find elem with magic text
elem = doc.root.find_element("18+")

# Find containing table and handle each cell
table = elem.find_parent("table")
num_shows = 0
table.elements.each("tr") do |row|
  index = 0
  show = {}
  
  begin
    row.elements.each("td") do |cell|
      handle_cell(index, cell, show)
      index += 1
    end
    
    num_shows += 1
    puts "Show (#{num_shows}):"
    puts "Date: #{show[:date]}"
    puts "Time: #{show[:time]}"
    puts show[:bands]
    puts ""
    
  rescue Exception => e
    # Skip this one
    #puts "#{e}\n\n"
    #p e.backtrace
  end
end



