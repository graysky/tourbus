# Schema as of Sun Feb 18 18:07:46 Eastern Standard Time 2007 (schema version 43)
#
#  id                  :integer(11)   not null
#  fan_id              :integer(11)   default(0), not null
#  friend_id           :integer(11)   default(0), not null
#  created_on          :datetime      
#

class Friendship < ActiveRecord::Base
  belongs_to :fan
  belongs_to :friend, :class_name => 'Fan', :foreign_key => 'friend_id'
end
