class TurkWorker < ActiveRecord::Base
  has_many :turk_hits
end