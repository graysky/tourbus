class CreateFanServices < ActiveRecord::Migration
  def self.up
    create_table :fan_services do |t|
      t.column :fan_id, :integer, :null => false
      t.column :lastfm_username, :string
      t.column :lastfm_poll, :boolean, :default => false
    end
    
    Fan.transaction do
      Fan.find(:all).each do |fan|
        fan.fan_services = FanServices.new
        fan.save!
      end
    end
  end

  def self.down
    drop_table :fan_services
  end
end
