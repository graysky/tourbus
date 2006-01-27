class Uuids < ActiveRecord::Migration
  def self.up
    # We want a unique id for each user
    add_column :bands, :uuid, :string, :limit => 40
    add_column :fans, :uuid, :string, :limit => 40
  end

  def self.down
    remove_column :bands, :uuid
    remove_column :fans, :uuid
  end
end
