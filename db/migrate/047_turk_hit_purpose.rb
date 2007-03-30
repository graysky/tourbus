class TurkHitPurpose < ActiveRecord::Migration
  def self.up
    add_column :turk_hits, :purpose, :integer
    add_column :turk_sites, :last_approved_hit_id, :integer
  end

  def self.down
    remove_column :turk_hits, :purpose
    remove_column :turk_sites, :last_approved_hit_id
  end
end
