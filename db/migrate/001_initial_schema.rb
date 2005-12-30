# Initial schema brought into Migration framework
# This will contain all the tables up to the point of running it in production.
# The tables will be seeded from the schema.rb generated from:
# rake db_schema_dump
# To move to the latest migration:
# rake migrate
# Or to a specific version
# rake migrate VERSION=###
# To run in production environment, use:
# rake environment RAILS_ENV=production migrate
#
class InitialSchema < ActiveRecord::Migration
  
  def self.down
    # This would essentially drop the db which can be done with
    # rake migrate VERSION=0
    # The only table left is schema_info
  end
  
  def self.up
    # In addition to the regular table created below, there is an additional
    # table added by Rail migration named "schema_info" with which version of the
    # schema is present.
    
    # Create all the regular tables for TourBus
    create_table "band_services", :force => true do |t|
      t.column "band_id", :integer, :limit => 10, :default => 0, :null => false
      t.column "myspace_username", :string, :limit => 100, :default => "", :null => false
      t.column "myspace_password", :string, :limit => 40, :default => "", :null => false
      t.column "purevolume_username", :string, :limit => 100, :default => "", :null => false
      t.column "purevolume_password", :string, :limit => 40, :default => "", :null => false
    end
    
    create_table "bands", :force => true do |t|
      t.column "name", :string, :limit => 100, :default => "", :null => false
      t.column "band_id", :string, :limit => 100, :default => "", :null => false
      t.column "contact_email", :string, :limit => 100, :default => "", :null => false
      t.column "zipcode", :string, :limit => 5
      t.column "city", :string, :limit => 100, :default => ""
      t.column "state", :string, :limit => 2, :default => ""
      t.column "bio", :text
      t.column "salt", :string, :limit => 40, :default => ""
      t.column "official_website", :string, :limit => 100, :default => ""
      t.column "salted_password", :string, :limit => 40, :default => "", :null => false
      t.column "logo", :string, :limit => 100, :default => ""
      t.column "confirmed", :boolean, :default => false
      t.column "confirmation_code", :string, :limit => 50, :default => ""
      t.column "claimed", :boolean, :default => true
      t.column "created_on", :datetime
      t.column "page_views", :integer, :limit => 10, :default => 0
    end
    
    add_index "bands", ["name"], :name => "name_key"
    add_index "bands", ["band_id"], :name => "band_id_key"
    
    create_table "bands_shows", :id => false, :force => true do |t|
      t.column "band_id", :integer, :limit => 10, :default => 0, :null => false
      t.column "show_id", :integer, :limit => 10, :default => 0, :null => false
      t.column "can_edit", :boolean, :default => false, :null => false
    end
    
    add_index "bands_shows", ["show_id"], :name => "fk_bs_show"
    
    create_table "comments", :force => true do |t|
      t.column "body", :text
      t.column "created_at", :timestamp
      t.column "show_id", :integer, :limit => 10
      t.column "band_id", :integer, :limit => 10
      t.column "venue_id", :integer, :limit => 10
      t.column "photo_id", :integer, :limit => 10
      t.column "created_by_fan_id", :integer, :limit => 10
      t.column "created_by_band_id", :integer, :limit => 10
    end
    
    add_index "comments", ["show_id"], :name => "fk_sc_show"
    add_index "comments", ["band_id"], :name => "fk_cp_band"
    add_index "comments", ["venue_id"], :name => "fk_cp_venue"
    add_index "comments", ["photo_id"], :name => "fk_cp_photo"
    add_index "comments", ["created_by_band_id"], :name => "fk_cp_createdband"
    add_index "comments", ["created_by_fan_id"], :name => "fk_cp_createdfan"
    
    create_table "fans", :force => true do |t|
      t.column "name", :string, :limit => 100, :default => "", :null => false
      t.column "real_name", :string, :limit => 100, :default => "", :null => false
      t.column "contact_email", :string, :limit => 100, :default => "", :null => false
      t.column "zipcode", :string, :limit => 5
      t.column "city", :string, :limit => 100, :default => ""
      t.column "state", :string, :limit => 2, :default => ""
      t.column "bio", :text
      t.column "salt", :string, :limit => 40
      t.column "website", :string, :limit => 100, :default => ""
      t.column "salted_password", :string, :limit => 40, :default => "", :null => false
      t.column "logo", :string, :limit => 100, :default => "", :null => false
      t.column "confirmed", :boolean, :default => false, :null => false
      t.column "confirmation_code", :string, :limit => 50, :default => ""
      t.column "created_on", :datetime
      t.column "page_views", :integer, :limit => 10, :default => 0
    end
    
    add_index "fans", ["name"], :name => "name_key"
    
    create_table "photos", :force => true do |t|
      t.column "filename", :string, :limit => 100
      t.column "description", :text, :default => "", :null => false
      t.column "created_on", :datetime, :null => false
      t.column "page_views", :integer, :limit => 10, :default => 0
      t.column "show_id", :integer, :limit => 10
      t.column "band_id", :integer, :limit => 10
      t.column "venue_id", :integer, :limit => 10
      t.column "created_by_fan_id", :integer, :limit => 10
      t.column "created_by_band_id", :integer, :limit => 10
    end
    
    add_index "photos", ["show_id"], :name => "fk_sp_show"
    add_index "photos", ["band_id"], :name => "fk_sp_band"
    add_index "photos", ["venue_id"], :name => "fk_sp_venue"
    add_index "photos", ["created_by_band_id"], :name => "fk_sp_createdband"
    add_index "photos", ["created_by_fan_id"], :name => "fk_sp_createdfan"
    
    create_table "shows", :force => true do |t|
      t.column "cost", :string, :limit => 50
      t.column "title", :string, :limit => 100
      t.column "description", :text, :default => "", :null => false
      t.column "url", :string, :limit => 100, :default => "", :null => false
      t.column "date", :datetime, :null => false
      t.column "page_views", :integer, :limit => 10, :default => 0
      t.column "venue_id", :integer, :limit => 10, :default => 0, :null => false
    end
    
    add_index "shows", ["venue_id"], :name => "fk_venue"
    
    create_table "tags", :force => true do |t|
      t.column "name", :string, :limit => 100, :default => "", :null => false
    end
    
    create_table "tags_bands", :force => true do |t|
      t.column "band_id", :integer, :limit => 10, :default => 0, :null => false
      t.column "tag_id", :integer, :limit => 10, :default => 0, :null => false
      t.column "tag_type", :integer, :limit => 10, :default => 0, :null => false
    end
    
    add_index "tags_bands", ["band_id"], :name => "fk_bt_band"
    add_index "tags_bands", ["tag_id"], :name => "fk_bt_tag"
    
    create_table "tags_shows", :force => true do |t|
      t.column "show_id", :integer, :limit => 10, :default => 0, :null => false
      t.column "tag_id", :integer, :limit => 10, :default => 0, :null => false
      t.column "tag_type", :integer, :limit => 10, :default => 0, :null => false
    end
    
    add_index "tags_shows", ["show_id"], :name => "fk_st_show"
    add_index "tags_shows", ["tag_id"], :name => "fk_st_tag"
    
    create_table "tags_venues", :force => true do |t|
      t.column "venue_id", :integer, :limit => 10, :default => 0, :null => false
      t.column "tag_id", :integer, :limit => 10, :default => 0, :null => false
      t.column "tag_type", :integer, :limit => 10, :default => 0, :null => false
    end
    
    add_index "tags_venues", ["venue_id"], :name => "fk_vt_venue"
    add_index "tags_venues", ["tag_id"], :name => "fk_vt_tag"
    
    create_table "tours", :force => true do |t|
      t.column "band_id", :integer, :limit => 10, :default => 0, :null => false
      t.column "name", :string, :limit => 100, :default => "", :null => false
    end
    
    add_index "tours", ["band_id"], :name => "FK_tours_band_id"
    
    create_table "upload_addrs", :force => true do |t|
      t.column "address", :string, :limit => 100, :default => "", :null => false
      t.column "fan_id", :integer, :limit => 10
      t.column "band_id", :integer, :limit => 10
    end
    
    add_index "upload_addrs", ["band_id"], :name => "fk_cu_createdband"
    add_index "upload_addrs", ["fan_id"], :name => "fk_cu_createdfan"
    add_index "upload_addrs", ["address"], :name => "name_key"
    
    create_table "venues", :force => true do |t|
      t.column "name", :string, :limit => 100, :default => "", :null => false
      t.column "url", :string, :limit => 100, :default => "", :null => false
      t.column "address", :string, :default => "", :null => false
      t.column "city", :string, :limit => 100, :default => "", :null => false
      t.column "state", :string, :limit => 2, :default => "", :null => false
      t.column "zipcode", :string, :limit => 10, :default => "", :null => false
      t.column "country", :string, :limit => 45, :default => "", :null => false
      t.column "phone_number", :string, :limit => 15, :default => "", :null => false
      t.column "description", :text, :default => "", :null => false
      t.column "contact_email", :string, :limit => 100, :default => "", :null => false
      t.column "latitude", :string, :limit => 30
      t.column "longitude", :string, :limit => 30
      t.column "page_views", :integer, :limit => 10, :default => 0
    end
    
    create_table "zip_codes", :id => false, :force => true do |t|
      t.column "zip", :string, :limit => 16, :default => "0", :null => false
      t.column "city", :string, :limit => 30, :default => "", :null => false
      t.column "state", :string, :limit => 30, :default => "", :null => false
      t.column "latitude", :float, :limit => 10, :default => 0.0, :null => false
      t.column "longitude", :float, :limit => 10, :default => 0.0, :null => false
      t.column "timezone", :integer, :limit => 2, :default => 0, :null => false
      t.column "dst", :boolean, :default => false, :null => false
      t.column "country", :string, :limit => 2, :default => "", :null => false
    end
    
    add_index "zip_codes", ["country", "zip"], :name => "pc"
    add_index "zip_codes", ["zip"], :name => "zip"
    add_index "zip_codes", ["latitude"], :name => "latitude"
    add_index "zip_codes", ["longitude"], :name => "longitude"
    add_index "zip_codes", ["country"], :name => "country"
    
  end
end