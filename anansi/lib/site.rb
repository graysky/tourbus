require 'net/http'
require 'uri'
require 'rexml/document'
require 'html/xmltree'
require 'anansi/lib/html'

# Represents a specific site to crawl or process.
class Site
  include REXML
  
  # The name of the site (automatically gleamed from the config filename)
  # It must be unique
  attr_reader :name
  
  # The URL of the site - can be a String or an Array
  attr_reader :url
  
  # Interval for often to check site, in days
  attr_reader :interval
  
  # The parent directory to where the site is stored
  attr_reader :site_dir
  
  # The type of parser to use for this site
  attr_reader :parser_type
  
  # The hash of variables currently known by the configuration
  attr_reader :variables
  
  # The hast of methods defined by the site
  attr_reader :methods
  
  # User agent to send with requests
  # DO NOT CHANGE
  USER_AGENT = 'tourbus'
  
  # Create a new site with:
  # parent_path => the parent directory of the site
  # this will affect where output is written and stored, ex.
  # [site_dir]/crawl => where files pulled in during the crawl are placed (stage1)
  # [site_dir]/archives => where files are put after being parsed (stage2)
  # name => optional name for this site
  def initialize(site_dir, name = nil)
    
    @variables = {}
    @methods = {}
    
    # Set the site directory
    set :site_dir, site_dir
    @site_dir = site_dir
    
    # Set the default name
    set :name, name
    @name = name
  end
  
  # Directory where the pages pulled in the crawl are stored
  def crawl_dir
    crawl_dir = File.join(site_dir, "crawl")
    
    # Make the dir if needed
    if not File.exists?(crawl_dir)
      FileUtils.mkdir_p(crawl_dir)
    end
    
    return crawl_dir
  end
  
  # Directory where the parsed pages are archived
  def archive_dir
    archive_dir = File.join(site_dir, "archive")
    
    # Make the dir if needed
    if not File.exists?(archive_dir)
      FileUtils.mkdir_p(archive_dir)
    end
    
    return archive_dir
  end
  
  # Directory where the parsed shows as YAML files are written
  def parse_dir
    parse_dir = File.join(site_dir, "parse")
    
    # Make the dir if needed
    if not File.exists?(parse_dir)
      FileUtils.mkdir_p(parse_dir)
    end
    
    return parse_dir
  end
  
  # Get the current list of files that the crawler found
  def crawled_files
    files = []
    
    # Grab all the crawled files in the crawl directory
    dir = Dir.new(crawl_dir)
    
    # Grab each site under the directory
    dir.each do |e|
    
      child = File.join(dir.path, e)
      # Only consider files
      next unless File.file?(child)
      # Only consider XML files
      next unless e =~ /.xml$/
      
      next if e =~ /sample.xml/ # Skip sample file
      
      # Add to the list with absolute path
      files << File.expand_path(child)
    end

    return files
  end
  
  # Archive the current crawled files
  def archive!
    # TODO Implement to actually move the crawled files to the archives
  end
  
  def to_s
    # TODO Make pretty  
      "#{@variables}"
  end
  
  ##
  ## Borrowed from the Switchtower configuration
  ##
  # Set a variable to the given value.
  def set(variable, value=nil, &block)
    # if the variable is uppercase, then we add it as a constant to the
    # actor. This is to allow uppercase "variables" to be set and referenced
    # in recipes.
    #if variable.to_s[0].between?(?A, ?Z)
    #klass = @actor.metaclass
    #klass.send(:remove_const, variable) if klass.const_defined?(variable)
    #klass.const_set(variable, value)
    #end
    
    value = block if value.nil? && block_given?
    @variables[variable] = value
    
    if !block_given?
      # Define the variable so it can be refferred to easily as "url"
      instance_variable_set( "@#{variable}", value)
    end
  end
  
  alias :[]= :set
  
  # Access a named variable. If the value of the variable responds_to? :call,
  # call will be invoked (without parameters) and the return value cached
  # and returned.
  def [](variable)
    if @variables[variable].respond_to?(:call)
      ## MGC turned this off
      ## self[:original_value][variable] = @variables[variable]
      set variable, @variables[variable].call
    end
    @variables[variable]
  end
  
  # Defines a new method on the site
  # name => name of the method
  # options => options for the method (only :args is supported)
  # block => the block to execute
  def method(name, options={}, &block)
    
    # Remember what methods were added
    # Array with proc and num of args
    args = options[:args] || 0
    value = [block, args]
    @methods[name] = value
    
    # Define the new method on the site
    create_method(self, name, value)
  end
  
  # Create new method for:
  # name => name of the method
  # value => [block, num of args it takes]
  # Returns the string to define the newly created method
  def create_method(obj, name, value)
    # Pull out the proc and num of arguments
    proc = value[0]
    num_args = value[1]
    
    # Just a list of unique var names
    l = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m"]
    
    # Build up a string like:
    # define_method(name) { |a, b| proc.call(a,b) }"
    # so that the overriden method is passed the right args
    cmd = "define_method(name) { "
    
    var_cmd = "| "
    proc_cmd = " proc.call("
    
    # Add in each argument
    i = 0
    while i < num_args
      if i == 0
        var_cmd = var_cmd + l[i]
        proc_cmd = proc_cmd + l[i]
      else
        # Put in comma to seperate them
        var_cmd = var_cmd + ", " + l[i]
        proc_cmd = proc_cmd + ", " + l[i]
      end
      
      i = i + 1
    end
    
    # Close off the string
    var_cmd = var_cmd + " |"
    proc_cmd = proc_cmd + " ) }"
    
    # Build the full command
    cmd = cmd + var_cmd + proc_cmd
    #return cmd
    obj.instance_eval(cmd)
  end
  
  # Crawl the site's page(s) and store them iff:
  # 1) The necessary amount of time has passed
  # 2) robots.txt allows it
  # Params:
  # root_path => base dir for this site. 
  # Return true if successful, false otherwise
  def crawl()
    
    # Name of the site
    name = @name
    # URLs to visit
    urls = []
    
    # Url could be a string or array
    url = @url
    
    # Handle single string
    if url.kind_of?(String)
      urls[0] = url
    elsif url.kind_of?(Array)
      urls = url
    end
    
    if urls.nil? or urls.empty?
      p "Site #{name} had no URLs configured - skipping"
      return false
    end
    
    # Get the site's uri and port for robots.txt checking
    uri = URI.parse(urls[0])
    
    http = Net::HTTP.new(uri.host, uri.port)
    
    # Visit each URL
    urls.each do |url|
      
      # Parse the URL    
      uri = URI.parse(url)
      
      if !allow_robots?(http, uri.path)
        p "#{name}: Robots.txt prevents crawling of #{uri.path}"
        next
      end
      
      http = Net::HTTP.new(uri.host, uri.port)
      # Visit the page
      
      debug "Crawling #{name} at #{uri.request_uri}"

      # Need to include query string, so use request uri
      resp = http.get(uri.request_uri, 'User-Agent' => USER_AGENT)
      
      # TODO We should check for METADATA tags that prevent robots
      # <META NAME="ROBOTS" CONTENT="NOINDEX"> or
      # <META NAME="ROBOTS" CONTENT="NOFOLLOW">
      
      # Convert HTML to XML and strip tags
      html = HTML::strip_tags(resp.body)
      
      html.gsub!(/&nbsp;/, ' ') # TODO Needed?
      
      parser = HTMLTree::XMLParser.new(false, false)
      parser.feed(html)
      
      # Get REXML doc
      doc = parser.document
      
      # Write the REXML out
      # TODO Need indiv. name per URL
      f = File.new(File.join(crawl_dir, name + ".xml"), "w")
      doc.write(f)
      
      # Uncomment to write the raw HTML
      #raw = File.new(File.join(crawl_dir, name + ".html"), "w")
      #raw.write(resp.body)
    end
    
    return true
  end
  
  # Get the metaclass for this object
  def metaclass
    class << self; self; end
  end
  
  private
  
  # Define a new method on this object
  def define_method(name, &block)
    metaclass.send(:define_method, name, &block)
  end
  
  # Checks the remote robots.txt file
  # See this site for documentation:
  # http://www.robotstxt.org
  # http => HTTP obj to request robots.txt
  # uri_path => The path we're requesting (like /site/shows.html)
  def allow_robots?(http, uri_path)
    
    if http.nil?
      p "HTTP obj was nil"
      return false
    end
    
    # Get the robots.txt, if it exists
    resp = http.get("/robots.txt", 'User-Agent' => USER_AGENT)
    
    # robots.txt doesn't exist
    if resp.code != '200'
      return true
    end
    
    body = resp.body
    
    # Entries come in lists like:
    # User-agent: *
    # Disallow: /
    # Disallow: /sub
    # Disallow: /sub/path
    
    # Boolean to know if we found a rule to check
    found_rule = false
    
    # Parse the body for rules that affect us
    body.each do |line| 
      # Clean up the line
      s = line.downcase.chomp
      
      # Skip comments
      next if s.match(/^#/)
      
      if s.match(/user-agent/)
        # Check for both * or our user agent string
        # If found, check the next lines for rules
        if s.match(/\*/) or s.match(/tourb/)
          found_rule = true
        else
          # The next set of rules doesn't apply to us
          found_rule = false
        end
      end
      
      # Need to check this rule because it applies to us
      # Looks for a "/" following the Disallow:
      # NOTE: This is very simplistic, doesn't check path ("/blah"), just assumes
      # we're blocked if they include anything like "/".
      if found_rule and s.match(/disallow/)
        # Pull out just the rule path
        rule = s.sub(/disallow:\s*/, '')

        # See if the rule appears in our request path
        if uri_path.index(rule)
          # This rule blocks us
          debug "**** robots.txt blocking rule: #{s}"
          return false
        end
      end
    end
    
    # No rule blocked us
    return true
  end
  
  # Print debugging string if testing
  def debug(str)
    debug = true # flip when done testing
    if debug
      puts "#{str}"
    end
  end
    
end