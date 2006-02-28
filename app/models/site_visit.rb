# Represents a Site that has been visited by the Anansi crawler
class SiteVisit < ActiveRecord::Base
  
  # The name of the site to visit must be unique
  validates_uniqueness_of :name

end
