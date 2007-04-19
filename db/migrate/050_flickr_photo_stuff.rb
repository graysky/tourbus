class FlickrPhotoStuff < ActiveRecord::Migration
  def self.up
    add_column :bands, :options, :integer, :default => 0
    
    create_table :flickr_photos do |t|
      t.column :band_id, :integer
      t.column :show_id, :integer
      t.column :venue_id, :integer
      t.column :photopage_url, :string
      t.column :thumbnail_source, :string
      t.column :medium_source, :string
      t.column :small_source, :string
      t.column :square_source, :string
      t.column :flickr_id, :string
      t.column :notes, :string
      t.column :title, :string
      t.column :owner, :string
      t.column :date, :datetime
      t.column :status, :integer, :default => 0
      t.column :created_at, :datetime
    end
    
    add_index :flickr_photos, :flickr_id
    add_index :flickr_photos, :band_id
    add_index :flickr_photos, :show_id
    add_index :flickr_photos, :venue_id
  end

  def self.down
    remove_column :bands, :options
    #drop_index :flickr_photos, :flickr_id
    #drop_index :flickr_photos, :band_id
    #drop_index :flickr_photos, :show_id
    #drop_index :flickr_photos, :venue_id
    drop_table :flickr_photos
  end
end
