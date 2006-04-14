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
    
    logger.info "Resaving objects..."
    self.resave_objects
  
    finish = Time.now.asctime
    logger.info "Finish nightly tasks at #{finish}"
  end
  
  protected
  
  # Save in chunks just to avoid huge AR memory usage
  def self.save_chunks(klass)
    klass.each_by_chunk do |obj|
      obj.no_update
      obj.save!
    end
  end
  
end