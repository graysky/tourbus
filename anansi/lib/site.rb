require 'net/http'
require 'uri'
require 'rexml/document'
require 'html/xmltree'
require 'anansi/lib/html'

# Represents a specific site to crawl or process.
class Site < MetaSite
  include REXML

  # The string used to originally define the site.
  # Hack to let the parser get the same methods with the correct "self"
  attr_accessor :site_contents

  # User agent to send with requests
  # DO NOT CHANGE
  USER_AGENT = 'tourbusbot'
  
  # Create a new site with:
  # parent_path => the parent directory of the site
  # this will affect where output is written and stored, ex.
  # [site_dir]/crawl => where files pulled in during the crawl are placed (stage1)
  # [site_dir]/archives => where files are put after being parsed (stage2)
  # name => optional name for this site
  def initialize(site_dir, name = nil)
    
    super()
    
    # Set the site directory
    set :site_dir, site_dir
    @site_dir = site_dir
    
    # Set the default name
    set :name, name
    @name = name

    # Set default interval to 2 days
    set :interval, 48
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
  
  def add_state(state)
    @states << state
  end
  
  # Archive the current crawled files
  def archive!
    # TODO Implement to actually move the crawled files to the archives
  end
  
  def venue_map(city)
    map = @venue_map[city.nil? ? nil : city.downcase]
    return map || @venue_map
  end
  
  def to_s
    # TODO Make pretty  
      "#{@variables}"
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
      puts "Site #{name} had no URLs configured - skipping"
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
        puts "#{name}: Robots.txt prevents crawling of #{uri.path}"
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
      
      html.gsub!(/&nbsp;/, ' ') unless @leave_nbsps # TODO Needed?
      
      # Delete comments, including misformatted ones
      html.gsub!(/<!(.*)->/, '')
      html.gsub!(/<!doctype(.*)>/, '')
      
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
  
  private
  
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
        if uri_path.index(rule) and !rule.empty?
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