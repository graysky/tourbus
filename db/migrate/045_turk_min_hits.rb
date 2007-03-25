class TurkMinHits < ActiveRecord::Migration
  def self.up
    add_column :turk_sites, :min_shows, :integer, :default => 8
  end

  def self.down
    remove_column :turk_sites, :min_shows
  end
end
