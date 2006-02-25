# Database helpers and utilities
class DbHelper

  # Clean up old sessions older than 1 day
  def self.delete_old_sessions
  
    # logger "Deleting old sessions"
    # p "Deleting old sessions"
    ActiveRecord::Base.connection.delete("DELETE FROM sessions WHERE updated_at < now() - 24*3600")
  end

end