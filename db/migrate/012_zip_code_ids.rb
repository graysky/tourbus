class ZipCodeIds < ActiveRecord::Migration
  def self.up
  
    # (Re)Create the table, using force to replace the old table and creating an ID column
    create_table "zip_codes", :force => true do |t|
      t.column "zip", :string, :limit => 16, :default => "0", :null => false
      t.column "city", :string, :limit => 30, :default => "", :null => false
      t.column "state", :string, :limit => 30, :default => "", :null => false
      t.column "latitude", :float, :limit => 10, :default => 0.0, :null => false
      t.column "longitude", :float, :limit => 10, :default => 0.0, :null => false
      t.column "timezone", :integer, :limit => 2, :default => 0, :null => false
      t.column "dst", :boolean, :default => false, :null => false
      t.column "country", :string, :limit => 2, :default => "", :null => false
    end
    
    add_index "zip_codes", ["country", "zip"], :name => "pc"
    add_index "zip_codes", ["zip"], :name => "zip"
    add_index "zip_codes", ["latitude"], :name => "latitude"
    add_index "zip_codes", ["longitude"], :name => "longitude"
    add_index "zip_codes", ["country"], :name => "country"
    
  end

  def self.down
  end
end
