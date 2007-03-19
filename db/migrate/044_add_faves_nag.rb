# Column to track reminding new fans about adding favorite bands
class AddFavesNag < ActiveRecord::Migration
  def self.up
    add_column :fans, :last_faves_reminder, :datetime
  end

  def self.down
    remove_column :fans, :last_faves_reminder
  end
end
