class MobileSettings < ActiveRecord::Migration

  def self.up
    # Changing fan settings for mobile email
    add_column :fans, :mobile_number, :string, :limit => 20
    add_column :fans, :carrier_type, :integer, :limit => 10, :default => "-1"
    
    remove_column :fans, :mobile_email
  end

  def self.down
    remove_column :fans, :carrier_type
    remove_column :fans, :mobile_number
    
    add_column :fans, :mobile_email, :string, :limit => 100, :default => ""
  end
end
