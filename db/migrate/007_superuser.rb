class Superuser < ActiveRecord::Migration
  def self.up
    # Certain fans are superusers and have admin privelages.
    add_column :fans, :superuser, :boolean, :default => false
  end

  def self.down
    remove_column :fans, :superuser
  end
end
