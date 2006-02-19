# Create the table for RailsCron tasks
class RailsCrons < ActiveRecord::Migration
  def self.up
    
    # Table to store rails cron jobs
    create_table "rails_crons", :force => true do |t|
      t.column :command, :text
      t.column :start, :integer
      t.column :finish, :integer
      t.column :every, :integer
      t.column :concurrent, :boolean
    end
  end

  def self.down
    drop_table :rails_crons
  end
end
