require 'uuidtools'

class FriendRequest < ActiveRecord::Base
  belongs_to :requester, :class_name => "Fan", :foreign_key => "requester_id"
  belongs_to :requestee, :class_name => "Fan", :foreign_key => "requestee_id"
  
  def initialize(options = {})
    super
    self.uuid = UUID.random_create.to_s
  end
  
end
