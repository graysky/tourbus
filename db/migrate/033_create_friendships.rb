class CreateFriendships < ActiveRecord::Migration
  def self.up
    create_table :friendships do |t|
      t.column :fan_id, :integer, :null => false
      t.column :friend_id, :integer, :null => false
      t.column :created_on, :datetime
    end
  end

  def self.down
    drop_table :friendships
  end
end
