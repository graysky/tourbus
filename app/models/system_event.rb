# Schema as of Sun Feb 18 18:07:46 Eastern Standard Time 2007 (schema version 43)
#
#  id                  :integer(11)   not null
#  name                :string(255)   
#  area                :string(255)   
#  level               :string(255)   
#  description         :string(255)   
#  created_at          :datetime      
#

class SystemEvent < ActiveRecord::Base

  WISHLIST = "wishlist"
  FAVORITES = "favorites"
  REMINDERS = "reminders"
  SHARING = "sharing"
  
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
