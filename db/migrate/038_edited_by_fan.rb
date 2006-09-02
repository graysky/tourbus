class EditedByFan < ActiveRecord::Migration
  def self.up
    add_column :shows, :edited_by_fan_id, :integer
    add_column :shows, :edited_by_band_id, :integer
  end

  def self.down
    remove_column :shows, :edited_by_fan_id
    remove_column :shows, :edited_by_band_id
  end
end
