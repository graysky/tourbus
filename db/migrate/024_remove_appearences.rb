class RemoveAppearences < ActiveRecord::Migration
  def self.up
    rename_table :appearences, :bands_shows
  end

  def self.down
    rename_table :bands_shows, :appearences
  end
end
