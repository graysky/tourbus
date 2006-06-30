class SystemEvent < ActiveRecord::Base

  WISHLIST = "wishlist"
  FAVORITES = "favorites"
  REMINDERS = "reminders"
  
  INFO = "INFO"
  WARNING = "WARNING"
  ERROR = "ERROR"
  
  class << self
    def create(name, area, level, description = nil)
      event = self.new(:name => name, :area => area, :level => level, :description => description)
      event.save
      event
    end
    
    def info(name, area, description = nil)
      create(name, area, INFO, description)
    end
    
    def warning(name, area, description = nil)
      create(name, area, WARNING, description)
    end
    
    def error(name, area, description = nil)
      create(name, area, ERROR, description)
    end
  end
end
