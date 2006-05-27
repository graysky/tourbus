class CreateFriendRequests < ActiveRecord::Migration
  def self.up
    create_table :friend_requests do |t|
      t.column :requester_id, :integer
      t.column :requestee_id, :integer
      t.column :message, :string
      t.column :created_on, :datetime
      t.column :uuid, :string, :limit => 40
      t.column :approved, :boolean, :default => false
      t.column :denied, :boolean, :default => false
    end
    
    add_index :friend_requests, :requester_id, :name => "FK_fr_req_requester_id"
    add_index :friend_requests, :requestee_id, :name => "FK_fr_req_requestee_id"
  end

  def self.down
    drop_table :friend_requests
    
    remove_index :friend_requests, :requestee_id
    remove_index :friend_requests, :requester_id
  end
end
