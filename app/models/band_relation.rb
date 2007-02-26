# Schema as of Sun Feb 18 18:07:46 Eastern Standard Time 2007 (schema version 43)
#
#  id                  :integer(11)   not null
#  band1_id            :integer(11)   default(0), not null
#  band2_id            :integer(11)   default(0), not null
#  strength            :float         default(0.0)
#  created_on          :datetime      
#

class BandRelation < ActiveRecord::Base
  belongs_to :band1, :class_name => 'Band', :foreign_key => 'band1_id'
  belongs_to :band2, :class_name => 'Band', :foreign_key => 'band2_id'
end
