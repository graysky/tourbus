# Bands have Links to other sites
class AddBandLinks < ActiveRecord::Migration

  def self.up
  
    create_table "links", :force => true do |t|

      t.column "type", :string, :null => false
      t.column "name", :string      
      t.column "data", :string
      t.column "band_id", :integer, :limit => 10
      t.column "updated_at", :datetime
      t.column "created_at", :datetime
    end    
  end
  
  def self.down
  
    drop_table :links
    
  end
end
