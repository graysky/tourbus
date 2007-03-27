class TurkSiteCategories < ActiveRecord::Migration
  def self.up
    create_table :turk_site_categories do |t|
      t.column :name, :string
      t.column :description, :string
    end
    
    add_column :turk_sites, :turk_site_category_id, :integer
  end

  def self.down
    drop_table :turk_site_categories
    remove_column :turk_sites, :turk_site_category_id
  end
end
