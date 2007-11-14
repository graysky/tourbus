class Tm < ActiveRecord::Migration
  def self.up
    add_column :bands, :tm_id, :string
    add_column :shows, :tm_id, :string
    add_column :venues, :tm_id, :string
  end

  def self.down
    remove_column :bands, :tm_id
    remove_column :venues, :tm_id
    remove_column :shows, :tm_id
  end
end
