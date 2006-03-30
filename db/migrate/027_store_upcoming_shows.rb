class StoreUpcomingShows < ActiveRecord::Migration
  def self.up
    add_column :venues, :num_upcoming_shows, :integer, :default => 0
    add_column :bands, :num_upcoming_shows, :integer, :default => 0
    add_column :fans, :num_upcoming_shows, :integer, :default => 0
  end

  def self.down
  end
end
