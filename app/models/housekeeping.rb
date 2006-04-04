# Periodic housekeeping actions
class Housekeeping

  # Resave any objects that need periodic updating of statistics or other attributes
  def self.resave_objects
    save_chunks(Venue)
    save_chunks(Band)
    save_chunks(Fan)
  end
  
  # Check all wishlists for bands that have been created today.
  def self.check_wish_lists
  
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