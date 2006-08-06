require 'rexml/document'
require 'parsedate'
require 'yaml'
require 'anansi/lib/rexml' # TEMP
require 'anansi/lib/show_parser' # TEMP
require 'anansi/lib/string' # TEMP

class DnaLoungeParser < ShowParser
  include REXML
  
  def parse
    @shows = []
    @doc.root.each_element("//item") do |item|
      @show = {}
      @show[:venue] = get_venue
      @show[:bands] = []
      
      # Pull the date from the title, example: "Aug 17 (Thu): SF Drag King Contest"
      date = item.elements[1].text.split('(')[0]
      
      @show[:date] = parse_as_date(date)
      next unless @show[:date]
      
      @show[:source_link] = item.elements[2].recursive_text
      
      next if item.elements[3].nil?

      # Text that includes band names      
      text = item.elements[3].text

      # Try to pull out the time
      times = text.scan(/[0-9]?:?[0-9]?[0-9]pm/)
      if !times.empty?
        #puts "Times are: #{times}"
        @show[:time] = times[0]
      end
      
      # Need to handle:
      # Main Room
      # Lounge
      # With DJs:
      # Performing Live
      idx = text.index('Main Room')
      
      if idx.nil?
        idx = text.index('Performing Live')
      end
      
      next if idx.nil?
        
      bands = text[idx, text.length]
      # Switch to have bands seperated by commas
      bands = HTML::strip_all_tags(bands.gsub('<BR>', ',')).split(',')
      
      bands.each_with_index do |band, i|
        band = probable_band(band, i, nil)
        @show[:bands] << band if band
      end
      
      next unless @show[:bands] && @show[:bands].size > 0
      @shows << @show
      
      # Try to pick up secondary lounge acts
      idx = text.index('Lounge:')
      
      if !idx.nil?
        @show2 = @show.clone
        @show2[:bands] = nil # Clear out bands
        bands = text[idx, text.length]
        # Switch to have bands seperated by commas
        bands = HTML::strip_all_tags(bands.gsub('<BR>', ',')).split(',')
      
        bands.each_with_index do |band, i|
          band = probable_band(band, i, nil)
          @show2[:bands] << band if band
        end
        
        next unless @show2[:bands] && @show2[:bands].size > 0
        @shows << @show2
      end

    end
    
    @shows
  end
end