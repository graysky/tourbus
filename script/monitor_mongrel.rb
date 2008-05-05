#!/usr/bin/env ruby

require 'open-uri'
require "rexml/document"

url = "http://tourb.us/fan/mike"

  begin
    response = open(url)
    # Wrap in thread / timeout
    # http://www.ruby-doc.org/stdlib/libdoc/timeout/rdoc/index.html
    # 
    #doc = Document.new(response.read)
    response.each do |line|
      # Check for "<title>mike."
    end
  rescue OpenURI::HTTPError => e
    puts "Error while reading #{url}"
  end


# try regular mongrel stop

# then force

# then restart
