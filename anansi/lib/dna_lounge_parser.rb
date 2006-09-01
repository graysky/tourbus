require 'rexml/document'
require 'parsedate'
require 'yaml'
require 'anansi/lib/rexml' # TEMP
require 'anansi/lib/show_parser' # TEMP
require 'anansi/lib/string' # TEMP

# Parse for the DNA Lounge RSS feed
class DnaLoungeParser < ShowParser
  include REXML
  
  def parse
    @shows = []
    @doc.root.each_element("//item") do |item|
      @show = {}
      @show[:venue] = get_venue
      @show[:bands] = []
      
      # Pull out the date
      item.each_element("dnalounge:date") do |d|
        date = d.text.split('(')[0]
        @show[:date] = parse_as_date(date)
      end
      
      # Parse the time
      item.each_element("dnalounge:time") do |t|
        #date = d.text.split('(')[0]
        @show[:time] = parse_as_time(t.text)
      end
      
      # More info link
      item.each_element("dnalounge:flyer") do |flyer|
        @show[:source_link] = flyer.text if !flyer.text.nil?
      end
      
      # Show title - should this be preamble?
      item.each_element("dnalounge:title") do |title|
        @show[:preamble] = title.text if !title.nil?
      end
      
      # Price
      item.each_element("dnalounge:price") do |price|
        @show[:cost] = parse_as_cost(price.text)
      end

      # Get the bands
      item.each_element("dnalounge:band") do |artist|
        url = artist.attribute("href") || nil
        band = probable_band(artist.text, 0, nil)
        band[:url] = url.to_s if !url.nil?
        @show[:bands] << band
      end
      
      item.each_element("dnalounge:dj") do |dj|
        url = dj.attribute("href") || nil
        band = probable_band(dj.text, 0, nil)
        band[:url] = url.to_s if !url.nil?
        @show[:bands] << band
      end
      
      item.each_element("dnalounge:performer") do |performer|
        url = performer.attribute("href") || nil
        band = probable_band(performer.text, 0, nil)
        band[:url] = url.to_s if !url.nil?
        @show[:bands] << band
      end
      
      next unless @show[:bands] && @show[:bands].size > 0
      @shows << @show
    end
    
    @shows
  end
end