class BandFanCoordinates < ActiveRecord::Migration
  def self.up
    add_column :bands, :latitude, :string, :limit => 30
    add_column :bands, :longitude, :string, :limit => 30
    add_column :fans, :latitude, :string, :limit => 30
    add_column :fans, :longitude, :string, :limit => 30
  end

  def self.down
    remove_column :bands, :latitude
    remove_column :bands, :longitude
    remove_column :fans, :latitude
    remove_column :fans, :longitude
  end
end
