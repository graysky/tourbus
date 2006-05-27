class RelatedBands < ActiveRecord::Migration
  def self.up
    create_table :band_relations do |t|
      t.column :band1_id, :integer, :null => false
      t.column :band2_id, :integer, :null => false
      t.column :strength, :float, :default => 0.0
      t.column :created_on, :datetime
    end
  end

  def self.down
    drop_table :band_relations
  end
end
