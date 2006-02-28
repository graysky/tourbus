require 'net/http'
require 'uri'
require 'rexml/document'
require 'html/xmltree'
require 'anansi/lib/html'

# Represents a specific site to crawl or process.
# TODO This will eventually have a relationship with an ActiveRecord class or become one.
# TODO Define what vars are valid.  
class Site
  include REXML
  
  # The name of the site (automatically gleamed from the config filename)
  # It must be unique
  attr_reader :name
  
  # The URL of the site - can be a String or an Array
  attr_reader :url
  
  # Interval for often to check site, in days
  attr_reader :interval
  
  # The hash of variables currently known by the configuration
  attr_reader :variables
  
  # The hast of methods defined by the site
  attr_reader :methods
  
  # User agent to send with requests
  # DO NOT CHANGE
  USER_AGENT = 'tourbus'
  
  # Defaults for a new site
  def initialize(name = nil)
    
    @variables = {}
    @methods = {}
    
    # Set the default name
    set :name, name
    @name = name
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
  # #call will be invoked (without parameters) and the return value cached
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
    
    puts "Defining new method: #{name} with #{options}"
    
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
  
  # Fetch the site's page(s) and store them iff:
  # 1) The necessary amount of time has passed
  # 2) robots.txt allows it
  # Params:
  # root_path => base dir to write output to
  # Return true if successful, false otherwise
  def fetch(root_path)
    
    # Name of the site
    name = @name #self[:name]
    # URLs to visit
    urls = []
    
    # TODO Need check of proper timing passing
    # for us to hit the site again
    
    # Url could be a string or array
    url = @url # self[:url]
    
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
    
    if !allow_robots?(http)
      p "#{name}: Robots.txt prevents crawling of #{uri.host}"
      return
    end
    
    dir = File.join(root_path, name)
    
    # Visit each URL
    urls.each do |url|
      
      # Parse the URL    
      uri = URI.parse(url)
      
      http = Net::HTTP.new(uri.host, uri.port)
      # Visit the page
      resp = http.get(uri.path, 'User-Agent' => USER_AGENT)
      
      #p "Response: #{resp.body}"
      
      # TODO We should check for METADATA tags that prevent robots
      # <META NAME="ROBOTS" CONTENT="NOINDEX"> or
      # <META NAME="ROBOTS" CONTENT="NOFOLLOW">
      
      # Convert HTML to XML and strip tags
      html = HTML::strip_tags(resp.body)
      
      parser = HTMLTree::XMLParser.new(false, false)
      parser.feed(html)
      
      # Get REXML doc
      doc = parser.document
      
      # Make needed directories and write the xml out
      FileUtils.mkdir_p(dir)
      f = File.new(File.join(dir, name + ".xml"), "w")
      
      #p "File is: #{f}"
      #p "Exists?  #{File.exists?(f)}"
      #p "Writable? #{File.writable?(f.to_s)}"
      
      # TODO Save to proper location      
      doc.write(f)
    end
    
    return true
  end
  
  # TODO sync with above
  def get_latest_pages(root_path)
    
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
  def allow_robots?(http)
    
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
    
    # Entries come in pairs like:
    #User-agent: *
    #Disallow: /
    
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
        # If found, check the next line for rule
        if s.match(/\*/) or s.match(/tourb/)
          found_rule = true
        else
          # The rule on the next line doesn't apply to us
          found_rule = false
        end
      end
      
      # Need to check this rule because it applies to us
      # Looks for a "/" following the Disallow:
      # NOTE: This is very simplistic, doesn't check path ("/blah"), just assumes
      # we're blocked if they include anything like "/".
      if found_rule and s.match(/disallow/)
        if s.match(/\//)
          # This rule blocks us
          p "Blocking rule: #{s}"
          return false
        end
      end
    end
    
    # No rule blocked us
    return true
  end
  
end