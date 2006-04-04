# Extends ActiveRecord classes with the ability to treat result sets as chunks of
# objects
module ActiveRecord                                             
  module Chunkable
  
    # Execute the given block (mandatory) on each item of this class.
    # Selects the records in chunks of the given size.
    def each_by_chunk(chunk_size = 500)
      offset = 0
      count = self.count
      
      self.transaction do
        while offset < count
          self.find(:all, :offset => offset, :limit => chunk_size).each do |obj|
            yield obj
          end
          
          offset += chunk_size
        end
      end
    end
    
  end
  
  class Base
    # Make this available in all active record classes
    class << self 
      include ActiveRecord::Chunkable
    end
  end
  
end