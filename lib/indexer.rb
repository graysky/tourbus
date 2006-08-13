require 'searchable'
class Indexer
  include FerretMixin::Acts::Searchable
  
  def self.index_db
    # Find recently updated/created objects and index them
    stats = IndexStatistics.find(:first) || IndexStatistics.new
    query = stats.last_indexed_on.nil? ? ["last_updated > ?", Time.now - 5.years] : ["last_updated > ?", stats.last_indexed_on]
    
    index_time = Time.now
    
    objects = Band.find(:all, :conditions => query) + 
              Show.find(:all, :conditions => query) + 
              Venue.find(:all, :conditions => query)
    begin
      objects.each do |obj|
        puts "Indexing #{obj.class.name} #{obj.id}"
        obj.ferret_save(:commit => false)
      end
      
      puts "Committing and optimizing..."
      self.commit(:optimize => true)
      
      stats.last_indexed_on = index_time
      stats.save!
    rescue Exception => e
      # Do not save the time of this indexing. We will want to try again next time.
      puts "Error during indexing: #{e}"
    end 
  
  end
end