# Schema as of Thu Mar 02 20:14:39 Eastern Standard Time 2006 (schema version 17)
#
#  id                  :integer(11)   not null
#  name                :string(255)   default(), not null
#  updated_at          :datetime      
#  created_at          :datetime      
#

# Represents a Site that has been visited by the Anansi crawler
class SiteVisit < ActiveRecord::Base
  
  # The name of the site to visit must be unique
  validates_uniqueness_of :name

end
