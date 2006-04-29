# Periodic housekeeping actions
class Housekeeping 

  # Resave any objects that need periodic updating of statistics or other attributes
  def self.resave_objects
    save_chunks(Venue)
    save_chunks(Band)
    save_chunks(Fan)
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

    logger.info "Resaving objects..."
    self.resave_objects
  
    finish = Time.now.asctime
    logger.info "Finish nightly tasks at #{finish}"
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
  def self.save_chunks(klass)
    klass.each_by_chunk do |obj|
      begin
        obj.no_update
        obj.save_without_validation!
      rescue ActiveRecord::RecordNotSaved => e
        puts "Trouble saving: #{obj}"
        logger.error "Error saving #{obj}: #{e.to_s}"
      end
    end
  end
  
end
