# AR record for when sites were visited by anansi
class AddSiteVisit < ActiveRecord::Migration

  def self.up
    
    
    create_table "site_visits", :force => true do |t|
      t.column "name", :string, :null => false
      t.column "updated_at", :datetime
      t.column "created_at", :datetime
    end
    
    add_index :site_visits, :name
  
  end

  def self.down
    
    remove_index :site_visits, :name
    
    drop_table :site_visits
  end
end
