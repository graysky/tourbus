# Periodic housekeeping actions
class Housekeeping

  # Resave any objects that need periodic updating of statistics or other attributes
  def self.resave_objects
    save_chunks(Venue)
    save_chunks(Band)
    save_chunks(Fan)
  end
  
  protected
  
  # Save in chunks just to avoid huge AR memory usage
  def self.save_chunks(klass, chunk_size = 500)
    offset = 0
    count = klass.count
    
    puts "Saving #{count} #{klass} objects..."
    klass.transaction do
      while offset < count
        klass.find(:all, :offset => offset, :limit => chunk_size).each do |obj|
          obj.no_update
          obj.save!
        end
        
        offset += chunk_size
      end
    end
  end
  
end