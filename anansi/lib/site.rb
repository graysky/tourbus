# Represents a specific site to crawl or process.
# TODO This will eventually have a relationship with an ActiveRecord class or become one.
# TODO Define what vars are valid.  
class Site
  
  # The name of the site (automatically gleamed from the config filename) 
  attr_reader :name
  
  # The URL of the site - can be a String or an Array
  attr_reader :url
  
  # Interval for often to check site, in days
  attr_reader :interval
  
  # The hash of variables currently known by the configuration
  attr_reader :variables
  
  # User agent to send with requests
  USER_AGENT = 'tourbus'
  
  # Defaults for a new site
  def initialize(name = nil)
    
    @variables = {}
    
    # Set the default name
    set :name, name
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
    p "Variable is: #{variable} = #{value}"
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
  def fetch
    
    # Name of the site
    name = [:name]
    # URLs to visit
    urls = []
    
    # TODO Need check of proper timing passing
    #
    
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
    
    # Visit each URL
    urls.each do |url|
      
      # Parse the URL    
      uri = URI.parse(url)
    
      http = Net::HTTP.new(uri.host, uri.port)
      # Visit the page
      resp = http.get(uri.path, 'User-Agent' => USER_AGENT)
      
      p "Response: #{resp.body}"
      
      # TODO Save to proper location
    end
    
  end
  
  private
  
  # Checks the remote robots.txt file
  def allow_robots?(http)
  
    if http.nil?
      p "HTTP obj was nil"
      return false
    end
  
    # TODO Add real checking
    #resp = http.get("/robots.txt", 'User-Agent' => USER_AGENT)
    
    # TODO Handle 404 response
    
    #p "Response: #{resp.body}"
  
    return true
  end
  
end