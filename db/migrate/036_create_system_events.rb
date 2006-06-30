class CreateSystemEvents < ActiveRecord::Migration
  def self.up
    create_table :system_events do |t|
      t.column :name, :string
      t.column :area, :string
      t.column :level, :string
      t.column :description, :string
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :system_events
  end
end
