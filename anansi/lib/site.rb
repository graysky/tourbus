# Represents a specific site to crawl.
# TODO This will eventually have a relationship with an ActiveRecord class or become one
# TODO Define what vars are valid
class Site
  
  # The name of the site (automatically gleamed from the config filename) 
  attr_reader :name
  
  # The URL of the site - can be a String or an Array
  attr_reader :url
  
  # Interval for often to check site, in days
  attr_reader :interval
  
  # The hash of variables currently known by the configuration
  attr_reader :variables
  
  # User agent to send
  USER_AGENT = 'tourb.us'
  
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
    if variable.to_s[0].between?(?A, ?Z)
      klass = @actor.metaclass
      klass.send(:remove_const, variable) if klass.const_defined?(variable)
      klass.const_set(variable, value)
    end
    
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
      self[:original_value][variable] = @variables[variable]
      set variable, @variables[variable].call
    end
    @variables[variable]
  end
  
  # Fetch the site
  def fetch
    
    # url could be an arry
    url = self[:url]
    
    p "Url is: #{url}"
    
    uri = URI.parse(url)
    
    # Works
    #res = Net::HTTP.get_response(uri)
    #p "Response: #{res.body}"
    
    http = Net::HTTP.new(uri.host, uri.port)
    
    resp = http.get("/robots.txt", 'User-Agent' => USER_AGENT)
    p "Response: #{resp.body}"
    
    resp = http.get(uri.path, 'User-Agent' => USER_AGENT)
    p "Response: #{resp.body}"
    
  end
  
end