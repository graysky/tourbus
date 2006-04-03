# Extends ActiveRecord classes with the ability to treat result sets as chunks of
# objects
module ActiveRecord                                             
  module Chunkable
  
    def self.each_by_chunk(chunk_size = 500)
      offset = 0
      count = self.count
      
      self.transaction do
        while offset < count
          self.find(:all, :offset => offset, :limit => chunk_size).each do |obj|
            puts "hi"
          end
          
          offset += chunk_size
        end
      end
    end
    
  end
end