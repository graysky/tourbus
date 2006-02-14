require 'net/http'
require 'uri'

# Represents a collection of sites to crawl and digest
#
class AnansiConfig
  
  # Defaults for a new configuration
  # testing => if this is a test run
  def initialize(testing = false)
    
    @testing = testing
    @sites = []
    @root_path = nil
  end
  
  # Create the configuration for the crawler at the top of the anansi directory
  # path => "#{RAILS_ROOT}/lib/anansi"
  def start(path)
    
    dir = Dir.new(path)
    
    puts "Anansi started at #{dir.path}"
    @root_path = dir.path
    
    # Load all the sites from here down
    load(File.join(dir.path, "config"))
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
        
      child = File.join(dir.path, e)
      # Only consider subdirs      
      next unless File.directory?(child)
      
      subdir = Dir.new(child)
      
      subdir.each do |f|
        
        # Only act on .rb files
        next unless f =~ /.rb$/
        
        # TODO Skip example file in production
        # next if f =~ /sample/  
        #p "Matched #{f}"
        
        # Get full path and read it in        
        file = File.join(subdir.path, f)
        
        str = File.read(file)
        
        name = f.sub(/.rb/, '')
        
        # Create a new site
        s = Site.new(name)
        
        # and pull in the config file
        s.instance_eval(str)
        
        # Add the site      
        @sites << s
      end
    end
  end
  
  # Perform the crawl and write HTML starting at the
  # path, like
  # #{path}/input/<site-name>/<file-name>
  def crawl()
    path = File.join(@root_path, "input")
    
    return if !valid_dir?(path)
    
    @sites.each do |s|
      # TODO push to real location
      # TODO Need check for 
      s.fetch(path)
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
  
end
