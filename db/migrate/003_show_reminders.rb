class ShowReminders < ActiveRecord::Migration
  def self.up
    # Fans need new columns for show reminders. The reminders are in minutes.
    # Defaults are 3 days and 6 hours.
    add_column :fans, :show_reminder_first, :integer, :limit => 10, :default => 4320
    add_column :fans, :show_reminder_second, :integer, :limit => 10, :default => 360
    
    # Fans need new columns for where reminders should be sent
    add_column :fans, :wants_email_reminder, :boolean, :default => true
    add_column :fans, :wants_mobile_reminder, :boolean, :default => false
    
    # When the most recent reminder was sent
    add_column :fans, :last_show_reminder, :datetime
    
  end

  def self.down
    remove_column :fans, :show_reminder_first
    remove_column :fans, :show_reminder_second
    
    remove_column :fans, :wants_email_reminder
    remove_column :fans, :wants_mobile_reminder
    
    remove_column :fans, :last_show_reminder
  end
end
