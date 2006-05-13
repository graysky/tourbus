require 'rexml/document'
require 'anansi/lib/rexml'
require 'anansi/lib/html'
require 'lib/string_helper'
require 'parsedate'
require 'anansi/lib/table_parser'
require 'anansi/lib/multi_table_parser'
require 'anansi/lib/mideast_parser'
require 'anansi/lib/tts_parser'
require 'anansi/lib/pas_parser'
require 'anansi/lib/jambase_parser'
require 'yaml'

# Runs stage 2 of the anansi system. 
class AnansiParser

  attr_reader :only_site

  # testing => set to true if this is a test run
  def initialize(testing = false)
    @testing = testing
    @sites = []
    @config = nil
  end
  
  # Only parse the site given - must match the name of the site
  def only_site=(site)
    if site.nil? or site.empty?
      @only_site = nil
    else
      @only_site = site # Only run this site if set
    end
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
      
      # If only_site is set, skip all others
      next if not @only_site.nil? and site.name != @only_site
      
      update_site_visit(site)
      
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
          when :mideast then
            parser = MidEastParser.new(xml)
          when :multi_table then
            parser = MultiTableParser.new(xml)
          when :tts then
            parser = TTsParser.new(xml)
          when :pas then
            parser = PAsParser.new(xml)
          else
            # Try to dynamically load the parse
            name = site.parser_type.to_s + '_parser'
            begin
              require 'anansi/lib/' + name
              
              parser = eval(name.camelize).new(xml)
            rescue => e
              puts "Count not load parser #{file}: #{e.to_s}"
              next
            end
        end
        
        # Apply the site's methods to the parser
        parser.site = site
      
        # Parse the REXML doc
    	begin
          parser.parse
    	rescue Exception => e
    	  puts "Error parsing site: #{site.name}, :#{e.to_s}"
    	  next
    	end

        all_shows = []
        # Gather all the shows as YAML
        parser.shows.each { |show| all_shows << show }
        
        # Create a file with the same name (with .yml ext) in the parse directory
        yml_file = File.new(File.join(site.parse_dir, File.basename(file, ".xml") + ".yml"), "w")
        
        # Write out the yaml file
        yml_file.write(all_shows.to_yaml)
      end
    end
  end
  
  protected
  
  # Update the site visit object based on the site variables
  def update_site_visit(site)
    visit = SiteVisit.find_by_name(site.name)
    if visit.nil?
      puts "Could not find site visit for: #{site.name}"
      return
    end
    
    visit.quality = site[:quality] if site[:quality]
    
    visit.no_update
    visit.save
  end
end