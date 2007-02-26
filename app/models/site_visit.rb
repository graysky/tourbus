# Schema as of Sun Feb 18 18:07:46 Eastern Standard Time 2007 (schema version 43)
#
#  id                  :integer(11)   not null
#  name                :string(255)   default(), not null
#  updated_at          :datetime      
#  created_at          :datetime      
#  quality             :integer(11)   default(5)
#  last_updated        :datetime      
#

# Represents a Site that has been visited by the Anansi crawler
class SiteVisit < ActiveRecord::Base
  
  # The name of the site to visit must be unique
  validates_uniqueness_of :name

  ATATURK_NAME = "ATATURK"
  
  def self.ataturk_site
    self.find_by_name(ATATURK_NAME)
  end
  
end
