# Periodic housekeeping actions
class Housekeeping 

  # Resave any objects that need periodic updating of statistics or other attributes
  def self.resave_objects
    save_chunks(Venue)
    save_chunks(Band)
  end

  # Run the long running tasks nightly
  def self.nightly_tasks
    start = Time.now.asctime
    logger = OFFLINE_LOGGER
    logger.info "Started nightly tasks at #{start}"
  
    logger.info "Starting wish list..."
    WishListBand.make_wishes_come_true
 
    logger.info "Poll last.fm for favorites"
    FanServices.poll_lastfm_faves
  
    logger.info "Sending favorites emails..."
    FavoritesMailer.do_favorites_updates

    logger.info "Sending add favorites reminder emails..."
    FavoritesMailer.do_add_favorites_reminder

    logger.info "Reporting stats..."
    self.report_stats
    
    logger.info "Delete old sessions..."
    DbHelper.delete_old_sessions    

    logger.info "Resaving objects..."
    self.resave_objects
  
    logger.info "Creating sitemap..."    
    self.create_sitemap
  
    finish = Time.now.asctime
    logger.info "Finish nightly tasks at #{finish}"
  end
  
  # Create sitemap for Google. 
  def self.create_sitemap
    start = Time.now.asctime
    logger = RAILS_DEFAULT_LOGGER
  
    sitemap = File.new("#{RAILS_ROOT}/public/sitemap.txt",  "w+")    
    puts "Creating sitemap at: #{sitemap.path}"
    
    # Put a few standard links in
    sitemap.puts "http://tourb.us"
    sitemap.puts "http://tourb.us/faq"
    sitemap.puts "http://tourb.us/tour"
    sitemap.puts "http://tourb.us/signup/fan"
    sitemap.puts "http://tourb.us/signup/band"
    sitemap.puts "http://tourb.us/login"
    # Add metro links
    sitemap.puts "http://tourb.us/metro/boston"
    sitemap.puts "http://tourb.us/metro/sanfran"
    sitemap.puts "http://tourb.us/metro/seattle"
    sitemap.puts "http://tourb.us/metro/la"
    sitemap.puts "http://tourb.us/metro/chicago"
    sitemap.puts "http://tourb.us/metro/austin"
    sitemap.puts "http://tourb.us/metro/nyc"
    sitemap.puts "http://tourb.us/metro/philadelphia"
    
    # Start counting
    urls = 0
    sitemap = get_sitemap(nil)
    
    shows = Show.find(:all)
    shows.each do |s|      
      if urls > 49990
        sitemap = get_sitemap(sitemap)
        urls = 0
      end
      
      sitemap.puts "http://tourb.us/show/#{s.id}"
      sitemap.puts "http://tourb.us/show/#{s.id}/fans"
      urls = urls + 2
    end
    puts "Added #{shows.length} shows to sitemap"
    
    bands = Band.find(:all)
    bands.each do |b|
      if urls > 49990
        sitemap = get_sitemap(sitemap)
        urls = 0
      end
      
      sitemap.puts "http://tourb.us/#{b.short_name}"
      sitemap.puts "http://tourb.us/#{b.short_name}/fans"
      sitemap.puts "http://tourb.us/#{b.short_name}/shows"
      urls = urls + 3
    end
    puts "Added #{bands.length} bands to sitemap"
    
    venues = Venue.find(:all)
    venues.each do |v|
      if urls > 49990
        sitemap = get_sitemap(sitemap)
        urls = 0
      end
      sitemap.puts "http://tourb.us/venue/#{v.id}"
      sitemap.puts "http://tourb.us/venue/#{v.id}/shows"
      urls = urls + 2
    end
    puts "Added #{venues.length} veneus to sitemap"
      
    fans = Fan.find(:all)
    fans.each do |f|
      if urls > 49990
        sitemap = get_sitemap(sitemap)
        urls = 0
      end
      sitemap.puts "http://tourb.us/fan/#{f.name}"
      sitemap.puts "http://tourb.us/fan/#{f.name}/bands"
      sitemap.puts "http://tourb.us/fan/#{f.name}/shows"
      urls = urls + 3
    end
    puts "Added #{fans.length} fans to sitemap"
    
  end
  
  protected

  # Print out some stats about tourbus
  def self.report_stats
  
    fans = Fan.find(:all)
    puts "Total fans: #{fans.size}"

    recent_fans = Fan.find(:all, :conditions => ["created_on > ?", Time.now - 1.days])
    puts "Recent fan signups (24hrs): #{recent_fans.size}"
    puts "[" + recent_fans.map {|f| f.name }.join(", ") + "]"

    recent_logins = Fan.find(:all, :conditions => ["last_login > ?", Time.now - 2.days])
    puts "Recent logins (48hrs): #{recent_logins.size}"
    puts "[" + recent_logins.map {|f| f.name }.join(", ") + "]"

    bands = Band.find(:all)
    puts "Total bands: #{bands.size}"

    venues = Venue.find(:all)
    puts "Total venues: #{venues.size}"

    shows = Show.find(:all)
    puts "Total shows: #{shows.size}"
    upcoming_shows = Show.find(:all, :conditions => ["date > ?", Time.now - 1.days])
    puts "Upcoming shows: #{upcoming_shows.size}"

    ""
  end 
  
  # Save in chunks just to avoid huge AR memory usage
  # Must be saving objects with num_upcoming_shows attribute
  def self.save_chunks(klass)
    logger = RAILS_DEFAULT_LOGGER
    
    klass.each_by_chunk(500, { :include => :upcoming_shows, :conditions => "num_upcoming_shows > 0" }) do |obj|
      begin
        
        before = obj.num_upcoming_shows
        obj.num_upcoming_shows = obj.upcoming_shows.size
        
        if before != obj.num_upcoming_shows
          obj.no_update
          obj.save_without_validation!
        end
        
      rescue ActiveRecord::RecordNotSaved => e
        puts "Error saving #{klass} with id: #{obj.id}: #{e.to_s}"
        logger.error "Error saving #{klass} with id: #{obj.id}: #{e.to_s}"
      end
    end
  end
  
  private
  
  # Return a new handle to a sitemap file if urls > 50K or the old sitemap handle
  # urls => number of URLs so far
  # sitemap => file handle
  def self.get_sitemap(sitemap)
    #return sitemap if urls < 49999 and !sitemap.nil?
    
    # Get the path to the file
    if sitemap.nil?
      s = "#{RAILS_ROOT}/public/sitemap0.txt"
    else
      s = sitemap.path.gsub(/\.txt/,'')
      s.next!
      s << ".txt"
    end
      
    # Create a new filehandle
    sitemap = File.new("#{s}",  "w+")
    puts "Creating sitemap at: #{sitemap.path}"
    return sitemap
  end
  
end
