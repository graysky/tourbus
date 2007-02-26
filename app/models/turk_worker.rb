# Schema as of Sun Feb 18 18:07:46 Eastern Standard Time 2007 (schema version 43)
#
#  id                  :integer(11)   not null
#  aws_worker_id       :string(255)   
#  completed_hits      :integer(11)   default(0)
#  reward_paid         :integer(11)   default(0)
#  added_shows         :integer(11)   default(0)
#  bonus_paid          :integer(11)   default(0)
#  last_paid_bonus_leve:integer(11)   default(0)
#

class TurkWorker < ActiveRecord::Base
  has_many :turk_hits
end
