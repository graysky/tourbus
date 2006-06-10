class ShowAttribution < ActiveRecord::Migration
  def self.up
    add_column :shows, :source_link, :string
    add_column :shows, :source_name, :string
  end

  def self.down
    remove_column :shows, :source_link
    remove_column :shows, :source_name
  end
end
