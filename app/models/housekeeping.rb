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
  
    start = Time.now
    urllist = File.new("#{RAILS_ROOT}/public/urllist.txt",  "w+")
    sitemap = File.new("#{RAILS_ROOT}/public/sitemap.txt",  "w+")    
    puts "Creating sitemap at: #{sitemap.path}"
    puts "Creating sitemap at: #{urllist.path}"
    
    # Put a few standard links in
    write_sitemap(sitemap, urllist, "http://tourb.us")
    write_sitemap(sitemap, urllist, "http://tourb.us/faq")
    write_sitemap(sitemap, urllist, "http://tourb.us/tour")
    write_sitemap(sitemap, urllist, "http://tourb.us/signup/fan")
    write_sitemap(sitemap, urllist, "http://tourb.us/signup/band")
    write_sitemap(sitemap, urllist, "http://tourb.us/login")
    # Add metro links
    write_sitemap(sitemap, urllist, "http://tourb.us/metro/boston")
    write_sitemap(sitemap, urllist, "http://tourb.us/metro/sanfran")
    write_sitemap(sitemap, urllist, "http://tourb.us/metro/seattle")
    write_sitemap(sitemap, urllist, "http://tourb.us/metro/la")
    write_sitemap(sitemap, urllist, "http://tourb.us/metro/chicago")
    write_sitemap(sitemap, urllist, "http://tourb.us/metro/austin")
    write_sitemap(sitemap, urllist, "http://tourb.us/metro/nyc")
    write_sitemap(sitemap, urllist, "http://tourb.us/metro/philadelphia")
    
    # Start counting
    urls = 0
    sitemap = get_sitemap(nil)
    
    Show.each_by_chunk(500, { :readonly => true }) do |s|
      begin
        if urls > 49990
          sitemap = get_sitemap(sitemap)
          urls = 0
        end
      
      write_sitemap(sitemap, urllist, "http://tourb.us/show/#{s.to_param}")
      write_sitemap(sitemap, urllist, "http://tourb.us/show/#{s.to_param}/fans")
      urls = urls + 2
      end
    end

    puts "Added #{Show.count} shows to sitemap"
 
    Band.each_by_chunk(500, { :readonly => true }) do |b|
      begin 
        if urls > 49990
          sitemap = get_sitemap(sitemap)
          urls = 0
        end
      
        write_sitemap(sitemap, urllist, "http://tourb.us/#{b.short_name}")
        write_sitemap(sitemap, urllist, "http://tourb.us/#{b.short_name}/fans")
        write_sitemap(sitemap, urllist, "http://tourb.us/#{b.short_name}/shows")
        urls = urls + 3
      end
    end
    puts "Added #{Band.count} bands to sitemap"
    
    Venue.each_by_chunk(500, { :readonly => true }) do |v|
      begin 
        if urls > 49990
          sitemap = get_sitemap(sitemap)
          urls = 0
        end
        write_sitemap(sitemap, urllist, "http://tourb.us/venue/#{v.to_param}")
        write_sitemap(sitemap, urllist, "http://tourb.us/venue/#{v.to_param}/shows")
        urls = urls + 2
      end
    end
    puts "Added #{Venue.count} veneus to sitemap"
      
    Fan.each_by_chunk(500, { :readonly => true }) do |f|
      begin
        if urls > 49990
          sitemap = get_sitemap(sitemap)
          urls = 0
        end
        write_sitemap(sitemap, urllist, "http://tourb.us/fan/#{f.name}")
        write_sitemap(sitemap, urllist, "http://tourb.us/fan/#{f.name}/bands")
        write_sitemap(sitemap, urllist, "http://tourb.us/fan/#{f.name}/shows")
        write_sitemap(sitemap, urllist, "http://tourb.us/fan/#{f.name}/friends")
        urls = urls + 3
      end
    end
    puts "Added #{Fan.count} fans to sitemap"
    
    urllist.close # Close filehandle
    
    finish = Time.now
    elapsed = finish - start
    puts "Sitemap creation took #{elapsed}"
  end

  # Print out some stats about tourbus
  def self.report_stats
  
    # Send nightly stats
    FeedbackMailer.deliver_nightly_stats()
  end 

  protected
  
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
  
  # Writes to both Google sitemap and Yahoo's urllist format
  def self.write_sitemap(sitemap, urllist, text)
    sitemap.puts text
    urllist.puts text
  end
  
  # Return a new handle to a sitemap file
  # sitemap => file handle
  def self.get_sitemap(sitemap)
    # Get the path to the file
    if sitemap.nil?
      s = "#{RAILS_ROOT}/public/sitemap0.txt"
    else
      s = sitemap.path.gsub(/\.txt/,'')
      sitemap.close # Close the old file
      s.next!
      s << ".txt"
    end
      
    # Create a new filehandle
    sitemap = File.new("#{s}",  "w+")
    puts "Creating sitemap at: #{sitemap.path}"
    return sitemap
  end
  
end
