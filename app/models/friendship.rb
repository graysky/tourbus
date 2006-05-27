class Friendship < ActiveRecord::Base
  belongs_to :fan
  belongs_to :friend, :class_name => 'Fan', :foreign_key => 'friend_id'
end
