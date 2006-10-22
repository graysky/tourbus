class SongSites < ActiveRecord::Migration
  def self.up
    create_table :song_sites do |t|
      t.column :url, :string
      t.column :crawl_status, :integer, :default => SongSite::CRAWL_STATUS_INACTIVE
      t.column :crawl_worker, :string
      t.column :last_crawl_comment, :string
      t.column :crawl_error, :boolean, :default => false
      t.column :crawled_songs, :integer, :default => 0
      t.column :crawl_error_count, :integer, :default => 0
      t.column :assigned_at, :datetime
      t.column :crawled_at, :datetime
      t.column :created_at, :datetime
    end
    
    create_table :songs do |t|
      t.column :band_id, :integer
      t.column :artist, :string
      t.column :title, :string
      t.column :song_site_id, :integer
      t.column :status, :integer, :default => Song::STATUS_OK
      t.column :album, :string
      t.column :year, :string
      t.column :url, :string
      t.column :size, :integer
      t.column :created_at, :datetime
      t.column :checked_at, :datetime
    end
  end

  def self.down
    drop_table :song_sites
    drop_table :songs
  end
end
