require 'net/http'
require 'uri'

# Represents a collection of sites to crawl and digest
#
class AnansiConfig
  
  attr_reader :sites
  
  attr_reader :only_site
  
  # Defaults for a new configuration
  # testing => if this is a test run
  def initialize(testing = false)
    @testing = testing
    @sites = []
    @root_path = nil
  end
  
  # Only crawl the site given - must match the name of the site
  def only_site=(site)
    if site.nil? or site.empty?
      @only_site = nil
    else
      @only_site = site # Only run this site if set
    end
  end
  
  # Create the configuration for the crawler at the top of the anansi directory
  # path => "#{RAILS_ROOT}/anansi/sites"
  def start(path = "#{RAILS_ROOT}/anansi/sites" )
    
    dir = Dir.new(path)
    
    debug "Anansi started [#{dir.path}]"
    @root_path = dir.path
    
    # Load all the sites from here down
    load(dir.path)
  end
  
  # Load a set of sites from a directory
  def load(path)
    
    if !valid_dir?(path)
      return
    end
    
    # Expect a directory. Descend into sub-dirs
    # for actual configs
    dir = Dir.new(path)
    
    # Grab each site under the directory
    dir.each do |e|
      # Skip ".", ".." and .svn dirs
      next if e == "."
      next if e == ".."
      next if e == ".svn"
      
      # Only read "sample" dir if we are testing
      next if !@testing and e == "sample"
      
      # Uncomment to *only* run the sample file for testing
      #next if @testing and e != "sample"
        
      child = File.join(dir.path, e)
      # Only consider subdirs      
      next unless File.directory?(child)
      
      subdir = Dir.new(child)
      
      # Assume the subdir is the state abbreviation
      state = e.upcase
      
      venue_map = {}
      # venue_map.rb is special, and contains a mapping for venue names to ids
      # for every site in this subdir (effectively one per state)
      file = File.join(subdir.path, 'venue_map.rb')
      if File.exist?(file)
        venue_map = instance_eval(File.read(file))
      end
      
      subdir.each do |f|
        
        # Only act on .rb files
        next unless f =~ /.rb$/ and f != 'venue_map.rb'
        
        # Get full path and read it in        
        file = File.join(subdir.path, f)
                
        str = File.read(file)
        
        name = f.sub(/.rb/, '')
        
        # Create a new site for each config file we find.
        # They each get their own directory for storing files
        s = Site.new(File.join(subdir.path, name), name)
        
        # Add the default state first so instance_eval has a chance to override it
        s.add_state(state)
        
        # and pull in the config file
        s.instance_eval(str)
        s.venue_map = venue_map
        # Stash away the string that defined the site
        s.site_contents = str
        
        # Add the site      
        @sites << s
      end
    end
    
    return @sites
  end
  
  # Perform the crawl for all the configured sites
  def crawl()
    
    @sites.each do |s|

      # If only_site is set, skip all others
      next if not @only_site.nil? and s.name != @only_site

      # Before visiting the site, check the interval to see
      # if we need to visit the site
      visit = SiteVisit.find_by_name(s.name)
      
      if visit.nil?
        # First visit to this site
        visit = SiteVisit.new
        visit.name = s.name
      
      # Check interval to see if it needs revisiting
      # Don't check during testing.
      elsif !@testing and Time.now - s.interval.hours < visit.updated_at
        # Skip it, we hit it within the defined interval
        p "Skipping site: #{s.name} because of time rule"
        next
      end
      
      # Crawl the site
      s.crawl
      
      # Save the visit
      if not visit.save
        p "**** Error saving SiteVisit for #{s.name}"
      end
      
    end
  end
  
  private
  
  # Check if this seems like a valid directory
  def valid_dir?(path)
    
    if path.nil? or path.empty?
      p "Path is invalid: #{path}"
      return false
    end
    
    return true
  end

  # Print debugging string if testing
  def debug(str)
    if @testing
      puts "#{str}"
    end
  end
  
end