class CreateFavoriteBandEvents < ActiveRecord::Migration
  def self.up
    create_table :favorite_band_events do |t|
      t.column :fan_id, :integer, :null => false
      t.column :band_id, :integer, :null => false
      t.column :event, :integer, :null => false
      t.column :source, :integer, :null => false
      t.column :description, :string
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :favorite_band_events
  end
end
