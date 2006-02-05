# Create a Sessions table
class SessionStore < ActiveRecord::Migration
  
  def self.up
    # NOTE: remember the "rake purge_sessions_table" task for cleaning up all sessions
    create_table "sessions", :force => true do |t|
      t.column "session_id", :string
      t.column "data", :text
      t.column "updated_at", :datetime
    end
    
    add_index "sessions", ["session_id"], :name => "sessions_session_id_index"
  end
  
  def self.down
    
    remove_index :sessions, :session_id
    drop_table :sessions
  end
end
