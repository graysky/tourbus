# Stamps objects with updated times unless told not to
module ActiveRecord
  module SelectiveTimestamp
    attr_accessor :skip_last_updated
    
    def self.append_features(base)
      super
      base.before_save :timestamp_last_updated
      base.after_save :reset_timestamp_control
    end
    
    def timestamp_last_updated
      write_attribute("last_updated", Time.now) if !@skip_last_updated and respond_to?(:last_updated)
    end
    
    def no_update
      @skip_last_updated = true
    end
    
    def reset_timestamp_control
      @skip_last_updated = false
    end
  end
  
  class Base
    # Make this available in all active record classes
    include ActiveRecord::SelectiveTimestamp
  end
end