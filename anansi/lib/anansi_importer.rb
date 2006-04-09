require 'yaml'
require 'uuidtools'

class AnansiImporter
  attr_reader :only_site
  attr_accessor :data_dir
  
  # Defaults for a new configuration
  # testing => if this is a test run
  def initialize(testing = false)
    @testing = testing
    @sites = []
    @root_path = nil
    @shows = []
    @prepare = true
    @import = false
    @show = nil
    @site = nil
    @data_dir = "#{RAILS_ROOT}/anansi/data"
    @imported_show_count = 0
    @new_band_count = 0
  end
  
  # Only crawl the site given - must match the name of the site
  def only_site=(site)
    if site.nil? or site.empty?
      @only_site = nil
    else
      @only_site = site # Only run this site if set
    end
  end
  
  # Load the site configs 
  def start()
    @config = AnansiConfig.new(@testing) 
    @config.start()
    @sites = @config.sites
  end
  
  def prepare
    @sites.each do |site|
      next if site.name == "sample" # Ignore sample site
      
      # If only_site is set, skip all others
      next if not @only_site.nil? and site.name != @only_site
      
      visit = SiteVisit.find_by_name(site.name)
      
      @site = site
      site.crawled_files.each do |file|
        path = File.join(site.parse_dir, File.basename(file, ".xml") + ".yml")
        
        YAML::load_documents(File.open(path)) do |shows|
          for show in shows
            @show = show
            show[:site] = site.name
            show[:site_visit_id] = visit.id
            
            prepare_show(show)
          end
        end
        
      end
    end
    
    save_shows
  end
  
  def latest_prepared_shows
    YAML::load_file(latest_data)
  end
  
  def import
    @shows = latest_prepared_shows
    
    begin
      Show.transaction do
          @shows.each do |show|
          if show[:status] == :ok
            result = import_show(show)
            show[:status] = :imported if result
          end
        end
      end
    ensure
      puts "Savings shows to YAML..."
      save_shows
    end
    
    puts "Imported #{@imported_show_count} shows and created #{@new_band_count} new bands"
  end
  
  def import_show(s)
    # Double check that this is not a duplicate.
    dup = duplicate_show(s)
    if dup and not s[:override_duplicate]
      puts "Skipping duplicate show: #{s[:date]} @ #{s[:venue][:name]}"
      return nil
    end
  
    puts "Importing show on #{s[:date]} @ #{s[:venue][:name]}"
    if dup
      show = dup
      show.bands.clear
    else
      show = Show.new
    end
    
    show.created_by_system = true
    show.date = s[:date]
    show.cost = s[:cost]
    show.description = s[:description] || ''
    show.preamble = s[:preamble]
    
    show.site_visit = SiteVisit.find(s[:site_visit_id])
    
    show.venue = Venue.find(s[:venue][:id])
    raise "Missing venue #{s[:venue][:id]}" if show.venue.nil?
    
    s[:bands].each { |band| add_band(show, band) }
    if !show.save
      puts "Error saving show"
      return nil
    end
    
    @imported_show_count += 1
    return show
  end
  
  def add_band(show, b)
    # TODO preamble, etc
    short_name = Band.name_to_id(b[:name])
    band = Band.find_by_short_name(short_name)
    
    if band.nil?
      puts "Creating a new band: #{b[:name]}"
      band =  Band.new
      band.claimed = false
      band.name = b[:name]
      band.short_name = short_name
      band.uuid = UUID.random_create.to_s
      
      # Add link to the band if we have one
      if b[:url]
        puts "Creating new Link #{b[:url]}"
        link = Link.new
        link.guess_link(b[:url])
        band.links << link
      end
      
      @new_band_count += 1
    end
   
    band.play_show(show, show.bands.size, b[:extra])
    band.save!
  end
  
  # Prepare a show hash for import
  def prepare_show(show)
    @shows << show
    
    clean_hash_text(show)
    
    show[:id] = @shows.size - 1
    show[:status] = :unknown
    
    # Combine the date and the time
    if !show[:time].nil?
      # Make sure the time has a colon before am/pm
      if !show[:time].include?(":")
        show[:time].gsub!(/am/i, ":00am")
        show[:time].gsub!(/pm/i, ":00pm")
      end
      
      show[:date] = Time.parse(show[:time], show[:date])
    end  
    
    if show[:date].nil?
      set_status(:skipped, "No date")
    elsif show[:bands].nil? or show[:bands].empty?
      set_status(:skipped, "No bands")
    elsif show[:date] < Time.new
      set_status(:skipped, "In the past")
    elsif !resolve_venue
      set_status(:review, "Unknown venue")
    elsif (dup = duplicate_show)
      if override_dup?(show, dup)
        set_status(:ok)
        show[:override_duplicate] = true
      else
        set_status(:skipped, "Duplicate") 
      end
    else
      set_status(:ok)
    end
    
    if show[:bands]
      preamble = show[:bands].first[:preamble]
      show[:preamble] = preamble if preamble and preamble != ''
    end
  end

  # Save all show data out to a yaml file
  def save_shows
    dir = File.join(@data_dir, 'latest')
    FileUtils.mkdir_p(dir) if not File.exists?(dir)
    yml_file = File.new(File.join(dir, 'shows.yaml'), "w")
    yml_file.write(@shows.to_yaml)
  end

  def save_shows_by_status(shows_by_status)
    @shows = []
    shows_by_status.each do |status, list|
      list.each do |show|
        @shows << show
      end
    end
    
    save_shows
  end

  protected
  
  def latest_data
    File.join(@data_dir, 'latest', 'shows.yaml')
  end
  
  def clean_hash_text(obj)
    if obj.is_a?(Hash)
      obj.each { |key, value| clean_hash_text(value) }
    elsif obj.is_a?(String)
      obj.replace(clean_text(obj))
    elsif obj.is_a?(Array)
      obj.each { |v| clean_hash_text(v) }
    end
  end
  
  def clean_text(str)
    str.gsub!(/&amp;/, '&')
    str.gsub!(/&apos;/, '\'')
    str.gsub!(/&quot;/, '"')
    str.gsub!(/\n/, '')
    
    return str.strip.squeeze(' ')
  end
  
  def set_status(status, explanation = "") 
    @show[:status] = status
    @show[:explanation] = explanation
  end
  
  def resolve_venue
    v = @show[:venue]
    
    # We're done if we already have a venue id
    return true if v[:id]
    
    # Assume we at least have the venue name
    # First try a lookup in the venue map
    @site.venue_map.each do |key, value|
      if (key.is_a?(String) and v[:name].downcase == key.downcase) or
         (key.is_a?(Regexp) and v[:name].downcase =~ key)
        v[:id] = value
        return true
      end
    end
    
    # Next try a db lookup in the venue's state, and city if we have it
    # TODO What about sites that do more than one state?
    # In that case I think we need a state for the individual record.
    if @site.states.size != 1
      puts "We only support looking up by default states if a site has exactly one. Site=#{@site.name}"
    end
    
    state = v[:state] || @site.states[0]
    if state
      venue = lookup_venue(v[:name], v[:city], state)
      if venue
        v[:id] = venue.id
        return true
      end
    end
    
    return false
  end
  
  def lookup_venue(name, city, state)
    short_name = Venue.name_to_short_name(name)
    conditions = get_venue_conditions(short_name, city, state)
    venue = Venue.find(:first, :conditions => conditions)
    
    if venue.nil?
      # Try with/without 'the'
      short_name = short_name.starts_with?('the') ? short_name[3..short_name.length] : 'the' + short_name
      conditions = get_venue_conditions(short_name, city, state)
      venue = Venue.find(:first, :conditions => conditions)
    end
      
    return venue
  end
  
  def get_venue_conditions(name, city, state)
    query = "short_name = ? and state = ?"
    query << " and city = ?" if city
    conditions = [query, name, state]
    conditions << city if city
    conditions
  end 
  
  def duplicate_show(s = @show)
    # Assume we already have a venue id
    min = s[:date].hour * 60 + s[:date].min
    max = 24 * 60 - min
    Show.find(:first, :conditions => ["venue_id = ? and date >= ? and date <= ?", 
                       s[:venue][:id], s[:date] - min.minutes, s[:date] + max.minutes])
  end
  
  def override_dup?(s, dup)
    return false if !dup.created_by_system or dup.site_visit.nil?
    
    visit = SiteVisit.find(s[:site_visit_id])
    return visit.quality > dup.site_visit.quality
  end
end