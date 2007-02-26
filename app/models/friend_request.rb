# Schema as of Sun Feb 18 18:07:46 Eastern Standard Time 2007 (schema version 43)
#
#  id                  :integer(11)   not null
#  requester_id        :integer(11)   
#  requestee_id        :integer(11)   
#  message             :string(255)   
#  created_on          :datetime      
#  uuid                :string(40)    
#  approved            :boolean(1)    
#  denied              :boolean(1)    
#

require 'uuidtools'

class FriendRequest < ActiveRecord::Base
  belongs_to :requester, :class_name => "Fan", :foreign_key => "requester_id"
  belongs_to :requestee, :class_name => "Fan", :foreign_key => "requestee_id"
  
  def initialize(options = {})
    super
    self.uuid = UUID.random_create.to_s
  end
  
end
