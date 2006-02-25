# Announcements of updates about TB
class AddAnnouncements < ActiveRecord::Migration
  def self.up
    
    create_table "announcements", :force => true do |t|
      t.column "applies_to", :string, :null => false
      t.column "teaser", :text, :null => false 
      t.column "message", :text, :null => false
      t.column "title", :text, :default => ""
      t.column "updated_at", :datetime
      t.column "created_at", :datetime
      t.column "expire_at", :datetime, :null => false
    end
  
  end

  def self.down

    drop_table :announcements
  end
end
