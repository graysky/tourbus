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
    
      @site = site
      site.crawled_files.each do |file|
        path = File.join(site.parse_dir, File.basename(file, ".xml") + ".yml")
        
        YAML::load_documents(File.open(path)) do |shows|
          for show in shows
            @show = show
            show[:site] = site.name
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
    YAML::load_documents(File.open(latest_data)) do |shows|
      Show.transaction do
        for show in shows
          import_show(show) if show[:status] == :ok
        end
      end
    end
    
    puts "Imported #{@imported_show_count} shows and created #{@new_band_count} new bands"
  end
  
  def import_show(s)
    puts "Importing show on #{s[:date]} @ #{s[:venue][:name]}"
    show = Show.new
    
    show.date = s[:date]
    show.cost = s[:cost]
    show.description = s[:description] || ''
    
    show.venue = Venue.find(s[:venue][:id])
    raise "Missing venue #{s[:venue][:id]}" if show.venue.nil?
    
    s[:bands].each { |band| add_band(show, band) }
    if !show.save
      puts "Error saving show"
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
      band.save!
      
      @new_band_count += 1
    end
    
    band.play_show(show)
  end
  
  # Prepare a show hash for import
  def prepare_show(show)
    @shows << show
    
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
    elsif show[:date] < Time.new
      set_status(:skipped, "In the past")
    elsif !resolve_venue
      set_status(:review, "Unknown venue")
    elsif duplicate_show?
      # TODO Update show information?
      set_status(:skipped, "Duplicate")
    else
      set_status(:ok)
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
    query = "name = ? and state = ?"
    query << " and city = ?" if city
    conditions = [query, name, state]
    conditions << city if city
   
    venues = Venue.find(:all, :conditions => conditions)
   
    # TODO Do anything special for dupes?
    return nil if venues.nil? or venues.size > 1
    return venues[0]
  end
  
  def duplicate_show?
    # Assume we already have a venue id
    min = @show[:date].hour * 60 + @show[:date].min
    max = 24 * 60 - min
    existing_show = Show.find(:first, :conditions => ["venue_id = ? and date >= ? and date <= ?", 
                                       @show[:venue][:id], @show[:date] - min.minutes, @show[:date] + max.minutes])
    return existing_show ? true : false
  end
end