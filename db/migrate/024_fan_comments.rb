# Allow comments on Fans
class FanComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :fan_id, :integer, :limit => 10
  end

  def self.down
    remove_column :comments, :fan_id
  end
end
