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

html = File.new('anansi/ohmyrockness.test.html').read
html = HTML::strip_tags(html)

puts "parse html..."
parser = HTMLTree::XMLParser.new(false, false)
parser.feed(html)

# Get rexml doc
doc = parser.document

puts "parse table..."
parser = TableParser.new(doc, "xxx")

parser.table_columns = { 0 => :date, 1 => :time, 2 => :bands, 
    3 => :venue, 4 => :age_limit, 5 => :cost, 6 => :ignore }

parser.parse


