class Appearences < ActiveRecord::Migration
  def self.up
    add_column :bands_shows, :extra_info, :string
    add_column :bands_shows, :set_order, :integer
    rename_table :bands_shows, :appearences
  end

  def self.down
    remove_column :appearences, :extra_info
    remove_column :appearences, :set_order
    rename_table :appearences, :bands_shows
  end
end
