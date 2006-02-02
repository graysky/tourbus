# Stamps objects with updated times unless told not to
module ActiveRecord
  module SelectiveTimestamp
    attr_accessor :skip_last_updated
    
    def before_save
      super
      write_attribute("last_updated", Time.now) if !@skip_last_updated and respond_to?(:last_updated)
    end
    
    def no_update
      @skip_last_updated = true
    end
    
    def after_save
      super
      @skip_last_updated = false
    end
  end
  
  class Base
    # Make this available in all active record classes
    include ActiveRecord::SelectiveTimestamp
  end
end