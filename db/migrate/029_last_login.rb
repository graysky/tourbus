class LastLogin < ActiveRecord::Migration
  def self.up
    add_column :fans, :last_login, :datetime
    add_column :bands, :last_login, :datetime
  end

  def self.down
    remove_column :fans, :last_login
    remove_column :bands, :last_login
  end
end
