class TurkHit < ActiveRecord::Base
  belongs_to :turk_site
  belongs_to :turk_worker
end