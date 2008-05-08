#!/usr/bin/env ruby
require 'open-uri'
require 'timeout'

# Attempts to fetch a page from tourb.us. Returns true if the site
# appears to be running smoothly, false otherwise
def site_running?()
  
  begin
    url = "http://tourb.us/fan/mike"
    # Try to fetch the url
    response = open(url)

    response.each do |line|
      # Check for a known page title
      if line =~ /<title>mike/i
        return true # shortcircuit
      end
    end
  rescue OpenURI::HTTPError => e
    puts "Error while reading #{url}"
  end

  return false # doesn't appear to have worked
end

# Restarts mongrel
def restart_mongrel()
  o = `sudo /etc/init.d/mongrel_cluster restart`
  puts o
end

# Check the site, and 
def do_check()
  timeout = 60 # how long should we wait?
  is_running = false
  begin 
    is_running = Timeout::timeout( timeout ) {
      # Something that should be interrupted if it takes too much time...
      site_running?
    }
  rescue Timeout::Error => e
    puts "Caught an exception! #{e}"
    is_running = false # timed out
  end
  
  #puts "Status is #{is_running}"
  if !is_running
    puts "tourb.us appears down. Restarting mongrel..."
    restart_mongrel
  end
  
end

# Perform the check...
do_check





