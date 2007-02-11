class TurkHit < ActiveRecord::Base
  belongs_to :turk_site
  belongs_to :turk_worker
  
  STATUS_OUTSTANDING = 1
  STATUS_COMPLETE = 2
end