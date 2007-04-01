class UpdateTitle < ActiveRecord::Migration
  def self.up
    add_column :turk_hit_types, :update_title, :string
    add_column :turk_hit_types, :review_title, :string
  end

  def self.down
    add_column :turk_hit_types, :update_title
    add_column :turk_hit_types, :review_title
  end
end
