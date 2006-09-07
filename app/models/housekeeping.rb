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
    logger = RAILS_DEFAULT_LOGGER
    logger.info "Started nightly tasks at #{start}"
  
    logger.info "Starting wish list..."
    WishListBand.make_wishes_come_true
  
    logger.info "Sending favorites emails..."
    FavoritesMailer.do_favorites_updates

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
    
    shows = Show.find(:all)
    shows.each do |s|
      sitemap.puts "http://tourb.us/show/#{s.id}"
      sitemap.puts "http://tourb.us/show/#{s.id}/fans"
    end
    puts "Added #{shows.length} shows to sitemap"
    
    # Need to split into 2 files because of 50K limit
    sitemap2 = File.new("#{RAILS_ROOT}/public/sitemap2.txt",  "w+")    
    puts "Creating sitemap at: #{sitemap2.path}"
    
    bands = Band.find(:all)
    bands.each do |b|
      sitemap2.puts "http://tourb.us/#{b.short_name}"
      sitemap2.puts "http://tourb.us/#{b.short_name}/fans"
      sitemap2.puts "http://tourb.us/#{b.short_name}/shows"
    end
    puts "Added #{bands.length} bands to sitemap2"
    
    venues = Venue.find(:all)
    venues.each do |v|
      sitemap2.puts "http://tourb.us/venue/#{v.id}"
      sitemap2.puts "http://tourb.us/venue/#{v.id}/shows"
    end
    puts "Added #{venues.length} veneus to sitemap2"
    
    fans = Fan.find(:all)
    fans.each do |f|
      sitemap2.puts "http://tourb.us/fan/#{f.name}"
      sitemap2.puts "http://tourb.us/fan/#{f.name}/bands"
      sitemap2.puts "http://tourb.us/fan/#{f.name}/shows"
    end
    puts "Added #{fans.length} fans to sitemap2"
    
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
  
end
