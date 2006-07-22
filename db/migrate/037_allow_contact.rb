class AllowContact < ActiveRecord::Migration
  def self.up
    add_column :fans, :allow_contact, :boolean, :default => true
  end

  def self.down
    remove_column :fans, :allow_contact
  end
end
