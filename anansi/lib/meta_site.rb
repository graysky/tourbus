# A base class that is common to the ShowParser and Site so that they both
# have access to the attributes and methods specified in the site file.
# Something of a hack to get "self" to resolve correctly, the site's contents are
# applied to both the Site and the ShowParser
class MetaSite

  # The name of the site (automatically gleamed from the config filename)
  # It must be unique
  attr_reader :name
  
  # Visible name exposed in the UI... not necessarily unique
  attr_reader :display_name
  
  # The url to link to for attribution
  attr_reader :display_url

  # The URL of the site - can be a String or an Array
  attr_reader :url
  
  # Interval for often to check site, in days
  attr_reader :interval
  
  # The parent directory to where the site is stored
  attr_reader :site_dir
  
  # An array of states that this site will have shows in
  attr_reader :states
  
  # The type of parser to use for this site
  attr_reader :parser_type
  
  # The hash of variables currently known by the configuration
  attr_reader :variables
  
  # The hast of methods defined by the site
  attr_reader :methods
  
  # If true don't replace nbsp's
  attr_reader :leave_nbsps
  
  # true if the site contents is already xml, not html
  attr_reader :xml
  
  # The map of venue aliases to venue ids
  attr_accessor :venue_map
  
  # Use the tidy xml parser, not htmltools
  attr_accessor :use_tidy
  
  # Set up the shared variables
  def initialize()
    @variables = {}
    @methods = {}
    @venue_map = {}
    @states = []
    @xml = false
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

  # Get the metaclass for this object
  def metaclass
    class << self; self; end
  end

  def display_name
    @display_name || @name
  end
  
  def display_url
    @display_url || @url
  end 

  def xml?
    @xml
  end

  # Find more urls to crawl in the given xml documetn
  def links_to_follow(xml_doc)
    nil
  end

  protected
  
  # Define a new method on this object
  def define_method(name, &block)
    metaclass.send(:define_method, name, &block)
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
 
    obj.instance_eval(cmd)
  end

end