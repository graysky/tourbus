class FixFanShows < ActiveRecord::Migration
  def self.up
    drop_table :fans_watching_shows
    add_column :fans_shows, :watching, :boolean, :default => false
    add_column :fans_shows, :attending, :boolean, :default => true
  end

  def self.down
    # no going back
  end
end
