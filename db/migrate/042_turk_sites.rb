class TurkSites < ActiveRecord::Migration
  def self.up
    create_table :turk_sites do |t|
      t.column :url, :string
      t.column :venue_id, :integer
      t.column :created_at, :datetime
      t.column :turk_hit_type_id, :integer
      t.column :price_override, :integer
      t.column :num_assignments, :integer, :default => 1
      t.column :extra_instructions, :string
      t.column :frequency, :integer
      t.column :lifetime, :integer, :default => 7.days
    end
    
    create_table :turk_hit_types do |t|
      t.column :aws_hit_type_id, :string
      t.column :name, :string
      t.column :price, :integer
      t.column :title, :string
      t.column :description, :string
      t.column :duration, :integer, :default => 1.hour
      t.column :keywords, :string
    end
    
    create_table :turk_hits do |t|
      t.column :turk_site_id, :integer
      t.column :submission_time, :datetime
      t.column :response_time, :datetime
      t.column :status, :integer, :default => 1
      t.column :amount_paid, :integer
      t.column :turk_worker_id, :integer
      t.column :aws_hit_id, :string
    end
    
    create_table :turk_workers do |t|
      t.column :aws_worker_id, :string
    end
  end

  def self.down
    drop_table :turk_sites
    drop_table :turk_hits
    drop_table :turk_hit_types
    drop_table :turk_workers
  end
end
