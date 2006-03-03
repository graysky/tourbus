# Schema as of Thu Mar 02 20:14:39 Eastern Standard Time 2006 (schema version 17)
#
#  id                  :integer(11)   not null
#  band_id             :integer(10)   default(0), not null
#  tag_id              :integer(10)   default(0), not null
#  tag_type            :integer(10)   default(0), not null
#

class TagBand < ActiveRecord::Base

end
