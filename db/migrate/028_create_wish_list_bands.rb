class CreateWishListBands < ActiveRecord::Migration
  def self.up
    create_table :wish_list_bands do |t|
      t.column :name, :string
      t.column :short_name, :string
      t.column :created_at, :datetime
      t.column :fan_id,  :integer
    end
    
    add_index :wish_list_bands, :fan_id, :name => "FK_wish_list_fan_id"
  end

  def self.down
    drop_table :wish_list_bands
    remove_index :wish_list_bands, :fan_id  
  end
end
