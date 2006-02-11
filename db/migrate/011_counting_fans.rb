class CountingFans < ActiveRecord::Migration
  def self.up
    add_column :bands, :num_fans, :integer, :default => 0
    add_column :shows, :num_attendees, :integer, :default => 0
    add_column :shows, :num_watchers, :integer, :default => 0
  end

  def self.down
    remove_column :bands, :num_fans
    remove_column :shows, :num_attendees
    remove_column :shows, :num_watchers
  end
end
