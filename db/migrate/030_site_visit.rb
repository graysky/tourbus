class SiteVisit < ActiveRecord::Migration
  def self.up
    add_column :site_visits, :quality, :integer, :default => 5
    add_column :site_visits, :last_updated, :datetime
    
    add_column :shows, :site_visit_id, :integer
    add_index :shows, [:site_visit_id], :name => "fk_show_site"
  end

  def self.down
    remove_column :site_visits, :quality
    remove_column :site_visits, :last_updated
    
    remove_index :shows, :site_visit_id
    remove_column :shows, :site_visit_id
  end
end
