class TurkSite < ActiveRecord::Base
  belongs_to :turk_hit_type
  belongs_to :venue
  
  validates_presence_of :url
  validates_presence_of :venue_id
  
  FREQUENCY_WEEKLY = 1
  FREQUENCY_BIWEEKLY = 2
  FREQUENCY_MONTHLY = 3
end