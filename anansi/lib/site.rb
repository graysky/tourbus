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
  attr_reader :name
  
  # The URL of the site - can be a String or an Array
  attr_reader :url
  
  # Interval for often to check site, in days
  attr_reader :interval
  
  # The hash of variables currently known by the configuration
  attr_reader :variables
  
  # User agent to send with requests
  # DO NOT CHANGE
  USER_AGENT = 'tourbus'
  
  # Defaults for a new site
  def initialize(name = nil)
    
    @variables = {}
    
    # Set the default name
    set :name, name
    @name = name
  end
  
  def to_s
    # TODO Make pretty  
      "#{@variables}"
  end
  
  ##
  ## Borrowed from the Switchtower config
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
    #p "Variable is: #{variable} = #{value}"
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
  
  # Fetch the site's page(s) and store them iff:
  # 1) The necessary amount of time has passed
  # 2) robots.txt allows it
  # Params:
  # root_path => base dir to write output to
  def fetch(root_path)
    
    # Name of the site
    name = self[:name]
    # URLs to visit
    urls = []
    
    # TODO Need check of proper timing passing
    # for us to hit the site again
    
    # Url could be a string or array
    url = self[:url]
    
    # Handle single string
    if url.kind_of?(String)
      urls[0] = url
    elsif url.kind_of?(Array)
      urls = url
    end
    
    if urls.nil? or urls.empty?
      p "Site #{name} had no URLs configured - skipping"
      return
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
    
  end
  
  # TODO sync with above
  def get_latest_pages(root_path)
    
  end
  
  private
  
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