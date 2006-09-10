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
