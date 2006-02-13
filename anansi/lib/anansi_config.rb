require 'net/http'
require 'uri'

# Represents a collection of sites to crawl and digest
# 
# 
#
class AnansiConfig
  
  # Defaults for a new configuration
  def initialize
    
    @sites = []
    @root_path = nil
  end
  
  # Create the configuration for the crawler at the top of the anansi directory
  # path => "#{RAILS_ROOT}/lib/anansi"
  def start(path)
    
    dir = Dir.new(path)
    
    puts "RIGHT Anansi started at #{dir.path}"
    @root_path = dir.path
    
    # Load all the sites
    load(File.join(dir.path, "config"))
  end
  
  # Load a set of sites from a directory
  def load(path)
    
    p "Read dir: #{path}"
    
    if path.nil? or path.empty?
      p "Path is empty"
      return
    end
    
    # Expect a directory
    dir = Dir.new(path)
    
    # Grab each site
    dir.each do |f|
      
      #p "Entry: [#{f}] class #{e.class}"
      
      # Only act on .rb files
      next unless f =~ /.rb/
      
      # TODO Skip example file
      # next if f =~ /sample/  
      p "Matched #{f}"
      
      # Get full path and read it in        
      file = File.join(dir.path, f)
      
      str = File.read(file)
      
      name = f.sub(/.rb/, '')
      
      #p "Name #{name}"
      
      # Create a new site
      s = Site.new(name)
      
      # and pull in the config file
      s.instance_eval(str)
      
      #p "URL: #{s[:url]}"
      
      @sites << s
      
      #p "Test: #{s}"
      
      # TODO push to real location
      # TODO Need check for 
      s.fetch
    end
  end
  
  # Perform the crawl and write HTML starting at the
  # path, like
  # #{path}/input/<site-name>/<file-name>
  def crawl()
    path = File.join(@root_path, "input")
    
  end
  
  private
  
  def valid_dir?(path)
  
  end
  
end
