# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 30) do

  create_table "announcements", :force => true do |t|
    t.column "applies_to", :string, :default => "", :null => false
    t.column "teaser", :text, :default => "", :null => false
    t.column "message", :text, :default => "", :null => false
    t.column "title", :text
    t.column "updated_at", :datetime
    t.column "created_at", :datetime
    t.column "expire_at", :datetime, :null => false
  end

  create_table "band_services", :force => true do |t|
    t.column "band_id", :integer, :limit => 10, :default => 0, :null => false
    t.column "myspace_username", :string, :limit => 100, :default => "", :null => false
    t.column "myspace_password", :string, :limit => 40, :default => "", :null => false
    t.column "purevolume_username", :string, :limit => 100, :default => "", :null => false
    t.column "purevolume_password", :string, :limit => 40, :default => "", :null => false
  end

  create_table "bands", :force => true do |t|
    t.column "name", :string, :limit => 100, :default => "", :null => false
    t.column "short_name", :string, :limit => 100, :default => "", :null => false
    t.column "contact_email", :string, :limit => 100, :default => "", :null => false
    t.column "zipcode", :string, :limit => 5
    t.column "city", :string, :limit => 100, :default => ""
    t.column "state", :string, :limit => 2, :default => ""
    t.column "bio", :text
    t.column "salt", :string, :limit => 40, :default => ""
    t.column "salted_password", :string, :limit => 40, :default => "", :null => false
    t.column "logo", :string, :limit => 100, :default => ""
    t.column "confirmed", :boolean, :default => false
    t.column "confirmation_code", :string, :limit => 50, :default => ""
    t.column "claimed", :boolean, :default => true
    t.column "created_on", :datetime
    t.column "page_views", :integer, :limit => 10, :default => 0
    t.column "security_token", :string, :limit => 40
    t.column "token_expiry", :datetime
    t.column "uuid", :string, :limit => 40
    t.column "last_updated", :datetime
    t.column "num_fans", :integer, :default => 0
    t.column "latitude", :string, :limit => 30
    t.column "longitude", :string, :limit => 30
    t.column "num_upcoming_shows", :integer, :default => 0
    t.column "last_login", :datetime
  end

  add_index "bands", ["name"], :name => "name_key"
  add_index "bands", ["short_name"], :name => "short_name_key"

  create_table "bands_fans", :id => false, :force => true do |t|
    t.column "band_id", :integer, :limit => 10, :default => 0, :null => false
    t.column "fan_id", :integer, :limit => 10, :default => 0, :null => false
  end

  add_index "bands_fans", ["fan_id"], :name => "FK_fave_fan_id"

  create_table "bands_shows", :id => false, :force => true do |t|
    t.column "band_id", :integer, :limit => 10, :default => 0, :null => false
    t.column "show_id", :integer, :limit => 10, :default => 0, :null => false
    t.column "can_edit", :boolean, :default => false, :null => false
    t.column "extra_info", :string
    t.column "set_order", :integer
  end

  add_index "bands_shows", ["show_id"], :name => "fk_bs_show"

  create_table "comments", :force => true do |t|
    t.column "body", :text
    t.column "created_on", :datetime
    t.column "show_id", :integer, :limit => 10
    t.column "band_id", :integer, :limit => 10
    t.column "venue_id", :integer, :limit => 10
    t.column "photo_id", :integer, :limit => 10
    t.column "created_by_fan_id", :integer, :limit => 10
    t.column "created_by_band_id", :integer, :limit => 10
    t.column "fan_id", :integer, :limit => 10
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
    t.column "last_favorites_email", :datetime
    t.column "default_radius", :integer, :limit => 6, :default => 35
    t.column "wants_favorites_emails", :boolean, :default => true, :null => false
    t.column "admin", :boolean, :default => false, :null => false
    t.column "security_token", :string, :limit => 40
    t.column "token_expiry", :datetime
    t.column "show_reminder_first", :integer, :limit => 10, :default => 4320
    t.column "show_reminder_second", :integer, :limit => 10
    t.column "wants_email_reminder", :boolean, :default => true
    t.column "wants_mobile_reminder", :boolean, :default => false
    t.column "last_show_reminder", :datetime
    t.column "uuid", :string, :limit => 40
    t.column "last_updated", :datetime
    t.column "superuser", :boolean, :default => false
    t.column "mobile_number", :string, :limit => 20
    t.column "carrier_type", :integer, :limit => 10, :default => -1
    t.column "show_watching_reminder", :integer, :limit => 10, :default => 4320, :null => false
    t.column "latitude", :string, :limit => 30
    t.column "longitude", :string, :limit => 30
    t.column "num_upcoming_shows", :integer, :default => 0
    t.column "last_login", :datetime
  end

  add_index "fans", ["name"], :name => "name_key"

  create_table "fans_shows", :id => false, :force => true do |t|
    t.column "show_id", :integer, :limit => 10, :default => 0, :null => false
    t.column "fan_id", :integer, :limit => 10, :default => 0, :null => false
    t.column "watching", :boolean, :default => false
    t.column "attending", :boolean, :default => true
  end

  add_index "fans_shows", ["fan_id"], :name => "FK_attending_fan_id"

  create_table "index_statistics", :force => true do |t|
    t.column "last_indexed_on", :datetime
  end

  create_table "links", :force => true do |t|
    t.column "name", :string
    t.column "data", :string
    t.column "band_id", :integer, :limit => 10
    t.column "updated_at", :datetime
    t.column "created_at", :datetime
  end

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

  create_table "rails_crons", :force => true do |t|
    t.column "command", :text
    t.column "start", :integer
    t.column "finish", :integer
    t.column "every", :integer
    t.column "concurrent", :boolean
  end

  create_table "sessions", :force => true do |t|
    t.column "session_id", :string
    t.column "data", :text
    t.column "updated_at", :datetime
  end

  add_index "sessions", ["session_id"], :name => "sessions_session_id_index"

  create_table "shows", :force => true do |t|
    t.column "cost", :string, :limit => 50
    t.column "title", :string, :limit => 100
    t.column "bands_playing_title", :string, :limit => 200
    t.column "description", :text, :default => "", :null => false
    t.column "url", :string, :limit => 100, :default => "", :null => false
    t.column "date", :datetime, :null => false
    t.column "page_views", :integer, :limit => 10, :default => 0
    t.column "venue_id", :integer, :limit => 10, :default => 0, :null => false
    t.column "created_by_fan_id", :integer, :limit => 10
    t.column "created_by_band_id", :integer, :limit => 10
    t.column "created_by_system", :boolean, :default => false, :null => false
    t.column "created_on", :datetime
    t.column "last_updated", :datetime
    t.column "num_attendees", :integer, :default => 0
    t.column "num_watchers", :integer, :default => 0
    t.column "preamble", :string
    t.column "site_visit_id", :integer
  end

  add_index "shows", ["venue_id"], :name => "fk_venue"
  add_index "shows", ["created_by_band_id"], :name => "fk_show_createdband"
  add_index "shows", ["created_by_fan_id"], :name => "fk_show_createdfan"
  add_index "shows", ["site_visit_id"], :name => "fk_show_site"

  create_table "site_visits", :force => true do |t|
    t.column "name", :string, :default => "", :null => false
    t.column "updated_at", :datetime
    t.column "created_at", :datetime
    t.column "quality", :integer, :default => 5
    t.column "last_updated", :datetime
  end

  add_index "site_visits", ["name"], :name => "site_visits_name_index"

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
    t.column "last_updated", :datetime
    t.column "short_name", :string
    t.column "num_upcoming_shows", :integer, :default => 0
  end

  create_table "wish_list_bands", :force => true do |t|
    t.column "name", :string
    t.column "short_name", :string
    t.column "created_at", :datetime
    t.column "fan_id", :integer
  end

  add_index "wish_list_bands", ["fan_id"], :name => "FK_wish_list_fan_id"

  create_table "zip_codes", :force => true do |t|
    t.column "zip", :string, :limit => 16, :default => "0", :null => false
    t.column "city", :string, :limit => 30, :default => "", :null => false
    t.column "state", :string, :limit => 30, :default => "", :null => false
    t.column "latitude", :float, :default => 0.0, :null => false
    t.column "longitude", :float, :default => 0.0, :null => false
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
