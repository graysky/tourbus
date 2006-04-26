# Change the default reminder times
class ChangeReminders < ActiveRecord::Migration
  
  def self.up
    # Change defaults to 7 days and 3 days
    # Weird, change_column_default was giving me strange errors.
    change_column :fans, :show_reminder_first, :integer, :limit => 10, :default => 10080
    change_column :fans, :show_reminder_second, :integer, :limit => 10, :default => 4320

    # And 7 days for watched shows
    change_column :fans, :show_watching_reminder, :integer, :limit => 10, :default => 10080
  end

  def self.down
  end
end
