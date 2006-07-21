# Extends ActiveRecord classes with the ability to treat result sets as chunks of
# objects
module ActiveRecord                                             
  module Chunkable
  
    # Execute the given block (mandatory) on each item of this class.
    # Selects the records in chunks of the given size.
    def each_by_chunk(chunk_size = 500, options = {})
      offset = 0
      count = self.count
      
      options[:offset] = offset
      options[:limit] = chunk_size
      
      while offset < count
        self.find(:all, options).each do |obj|
          yield obj
        end
        
        offset += chunk_size
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