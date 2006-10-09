require 'rexml/document'
require 'parsedate'
require 'yaml'
require 'anansi/lib/rexml' # TEMP
require 'anansi/lib/show_parser' # TEMP
require 'anansi/lib/string' # TEMP

# Parses the listing for the Black Cat
class BlackCatParser < TableParser
  include REXML
  
  # Parse out the shows from 
  def parse
    @shows = []
        
    table = find_table
    
    # Use scanner to move through text
    s = StringScanner.new(table.to_s)
    
    s.skip_until(/<td class='schedule'>/)
    # Skip comments too
    s.skip_until(/-->/)
    
    # The line separator
    sep = /<br\/><br\/>/

    # Examine each line that looks like:
    # THUR OCT 5- BE YOUR OWN PET, BLACK LIPS, THE POINTS	$12	mainstage	8:30
    while line = s.scan_until(sep)
      # Clean up the string before processing
      l = line.sub(sep,'').strip
      
      @show = {}
      @show[:venue] = get_venue
      @show[:bands] = []
      
      # Get the date
      idx = l.index('-')
      @show[:date] = parse_as_date(l.slice!(0,idx))
      l.slice!(0,1) # Cut the dash too
      
      # Get the band names up to the cost
      idx = l.index('$')
      idx = l.index("free") if idx.nil?
      next if idx.nil?
      
      # Pull out the names and clean them up
      raw = l.slice!(0, idx)      
      raw_bands = []
      raw_bands = HTML::strip_all_tags(raw.gsub(/<br(\/)?(\s)*>/i, "|")).split(',')

      i = 0
      bands = []
      raw_bands.each do |b|
        # Try to find a band name
        band = probable_band(b, i, nil)
        if band
          bands << band
        else
          puts "**** Not a band: #{b}"
        end
      
        i = i + 1
      end
      next if bands.size == 0
      @show[:bands] = bands

      # Get the cost
      l.strip!
      idx = l.index(/\s/)
      chunk = l.slice!(0, idx)
      cost = parse_as_cost(chunk)
      @show[:cost] = cost if !cost.nil?

      # Get the time after the stage
      idx = l.index("backstage")
      idx = l.index("mainstage") if idx.nil?
      if !idx.nil?
        l.slice!(0,idx + 9) # Remove 'backstage' or 'mainstage'
        l.strip!
        time = parse_as_time(l)
        @show[:time] = time if !time.nil?
      end
      
      #puts "Show #{show}"
      @shows << @show
    end
    
    @shows
  end
end