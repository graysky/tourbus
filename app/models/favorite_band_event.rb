# Schema as of Sun Feb 18 18:07:46 Eastern Standard Time 2007 (schema version 43)
#
#  id                  :integer(11)   not null
#  fan_id              :integer(11)   default(0), not null
#  band_id             :integer(11)   default(0), not null
#  event               :integer(11)   default(0), not null
#  source              :integer(11)   default(0), not null
#  description         :string(255)   
#  created_at          :datetime      
#

class FavoriteBandEvent < ActiveRecord::Base
  belongs_to :fan
  belongs_to :band
  
  EVENT_ADD = 1
  EVENT_REMOVE = 2
  
  SOURCE_FAN = 1
  SOURCE_WISHLIST = 2
  SOURCE_IMPORT = 3
  SOURCE_LASTFM_POLL = 4
  SOURCE_DUPE = 5
end
