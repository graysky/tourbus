class LastUpdated < ActiveRecord::Migration
  def self.up
    # Manually keep track of when an object is updated
    add_column :bands, :last_updated, :datetime
    add_column :venues, :last_updated, :datetime
    add_column :fans, :last_updated, :datetime
  end

  def self.down
    remove_column :bands, :last_updated
    remove_column :venues, :last_updated
    remove_column :fans, :last_updated
  end
end
