class MoreTurk < ActiveRecord::Migration
  def self.up
    add_column :turk_hits, :turk_hit_submission_id, :integer
    add_column :turk_hits, :aws_assignment_id, :string
    add_column :turk_hits, :aws_review_assignment_id, :string
    
    add_column :turk_sites, :last_hit_time, :datetime
    add_column :turk_sites, :group, :integer, :default => 0
    
    add_column :turk_workers, :completed_hits, :integer, :default => 0
    add_column :turk_workers, :rejected_hits, :integer, :default => 0
    add_column :turk_workers, :reward_paid, :integer, :default => 0
    add_column :turk_workers, :added_shows, :integer, :default => 0
    add_column :turk_workers, :bonus_paid, :integer, :default => 0
    add_column :turk_workers, :last_paid_bonus_level, :integer, :default => 0
    
    create_table :turk_hit_submissions do |t|
      t.column :params, :text
      t.column :turk_site_id, :integer
      t.column :token, :string
    end
    
    SiteVisit.new(:name => "ATATURK", :quality => 6).save!
  end

  def self.down
    remove_column :turk_hits, :turk_hit_submission_id
    remove_column :turk_hits, :aws_assignment_id
    remvoe_column :turk_hits, :aws_review_assignment_id
    remove_column :turk_sites, :last_hit_time
    remove_column :turk_sites, :group
    remove_column :turk_workers, :completed_hits
    remove_column :turk_workers, :rejected_hits
    remove_column :turk_workers, :reward_paid
    remove_column :turk_workers, :added_shows
    remove_column :turk_workers, :bonus_paid
    remove_column :turk_workers, :last_paid_bonus_level
    drop_table :turk_hit_submissions
  end
end
