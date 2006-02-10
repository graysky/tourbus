class Watching < ActiveRecord::Migration
  def self.up
    create_table "fans_watching_shows", :id => false, :force => true do |t|
      t.column "show_id", :integer, :limit => 10, :default => 0, :null => false
      t.column "fan_id", :integer, :limit => 10, :default => 0, :null => false
    end
    
    add_index "fans_watching_shows", ["fan_id"], :name => "FK_watching_fan_id"
    
    add_column :fans, :show_watching_reminder, :integer, :limit => 10, :default => 4320
  end

  def self.down
    
    drop_table :fans_watching_shows
    remove_column :fans, :show_watching_reminder
    remove_index :fans_watching_shows, :fan_id
  end
end
