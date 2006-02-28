require 'rubygems'
require 'html/xmltree'
require 'net/http'
require 'rexml/document'
require 'anansi/lib/rexml'
require 'anansi/lib/html'
require 'lib/string_helper'
require 'parsedate'
require 'anansi/lib/table_parser'

include REXML

# Hopefully this will work for other teaparty venues
# Downloaded from:
# http://www.teapartyconcerts.com/venues.html?venueID=371
path = 'C:\workspaces\acadia1\tourbus\anansi\sites\ma\paradise\crawl\paradise.xml'
#path = 'anansi/paradise.html'
html = File.new(path).read
html = HTML::strip_tags(html)

html.gsub!(/&nbsp;/, ' ')

puts "parse html..."
parser = HTMLTree::XMLParser.new(false, false)
parser.feed(html)

# Get rexml doc
doc = parser.document

puts "parse table..."
parser = TableParser.new(doc)

parser.marker_text << "Event Title" 

# Venue is always the Paradise

parser.table_columns = { 0 => [:date, :time], 1 => :bands}

parser.parse

