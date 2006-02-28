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

html = File.new('anansi/sf_list.html').read
html = HTML::strip_tags(html)

html.gsub!(/&nbsp;/, ' ')

puts "parse html..."
parser = HTMLTree::XMLParser.new(false, false)
parser.feed(html)

# Get rexml doc
doc = parser.document

puts "parse table..."
parser = TableParser.new(doc)

parser.table_columns = { 0 => [:date, :time], 1 => :bands, 2 => :venue, 3 => :cost }

parser.parse
