# Schema as of Sun Feb 18 18:07:46 Eastern Standard Time 2007 (schema version 43)
#
#  id                  :integer(11)   not null
#  url                 :string(255)   
#  venue_id            :integer(11)   
#  created_at          :datetime      
#  turk_hit_type_id    :integer(11)   
#  price_override      :integer(11)   
#  num_assignments     :integer(11)   default(1), not null
#  extra_instructions  :string(255)   
#  frequency           :integer(11)   
#  lifetime            :integer(11)   default(604800)
#  last_hit_time       :datetime      
#  group               :integer(11)   default(0)
#

class TurkSite < ActiveRecord::Base
  belongs_to :turk_hit_type
  belongs_to :venue
  
  validates_presence_of :url
  validates_presence_of :venue_id
  
  FREQUENCY_WEEKLY = 1
  FREQUENCY_BIWEEKLY = 2
  FREQUENCY_MONTHLY = 3

  def is_hit_due?
    d = case self.frequency
        when FREQUENCY_WEEKLY then 7.days
        when FREQUENCY_BIWEEKLY then 14.days
        when FREQUENCY_MONTH then 28.days
        end
        
    self.last_hit_time.nil? || (Time.now - d) > self.last_hit_time
  end
  
  def add_hit(hit_id)
    transaction do
      hit = TurkHit.new(:turk_site_id => self.id,
                        :aws_hit_id => hit_id,
                        :submission_time => Time.now)
                        
      hit.save!
      
      self.last_hit_time = Time.now
      self.save!
    end
  end
    
end
