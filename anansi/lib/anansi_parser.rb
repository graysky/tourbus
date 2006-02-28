require 'rexml/document'
require 'anansi/lib/rexml'
require 'anansi/lib/html'
require 'lib/string_helper'
require 'parsedate'
require 'anansi/lib/table_parser'

# Runs stage 2 of the anansi system. 
class AnansiParser

  # set testing to true if this is a test run
  def initialize(testing = false)
    @testing = testing
    @sites = []
    @config = nil
  end
  
  # Load the site configs 
  def start()
    @config = AnansiConfig.new(@testing) 
    @config.start()
    @sites = @config.sites
  end
  
  # Parse the configs found by the start method
  def parse
    @sites.each do |site| 
      next if site.name == "sample" # Ignore sample site
      
      # Parser each file for this site      
      site.crawled_files.each do |file|
        
        puts "Parsing site #{site.name} (#{file})"
        
        # File to parse
        xml = File.new(file).read
        
        # Determine type of parser
        case site.parser_type      
          when :table then
            # Use table parser
            parser = TableParser.new(xml)
          
          else
            puts "**** Error: Parser type not found!"
            next
        end
        
        # Apply the site's methods to the parser
        parser.site = site
      
        # Parse the REXML doc
        shows = parser.parse
      end
    end
  end
end