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

html = File.new('anansi/great_scott.test.html').read
html = HTML::strip_tags(html)

puts "parse html..."
parser = HTMLTree::XMLParser.new(false, false)
parser.feed(html)

# Get rexml doc
doc = parser.document

puts "parse table..."
parser = TableParser.new(doc)

parser.table_columns = { 0 => :date, 1 => :ignore, 2 => :bands, 3 => :time_age_cost }

parser.parse


