# Schema as of Sun Feb 18 18:07:46 Eastern Standard Time 2007 (schema version 43)
#
#  id                  :integer(11)   not null
#  band_id             :integer(10)   default(0), not null
#  tag_id              :integer(10)   default(0), not null
#  tag_type            :integer(10)   default(0), not null
#

class TagBand < ActiveRecord::Base

end
