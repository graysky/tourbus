# =============================================================================
# A set of rake tasks for dealing with tourbus actions
# =============================================================================

desc "Runs the 1st stage of the crawler"
task :anansi_crawl do

  # TODO Remove "true" which indicates testing
  cmd = <<END
  c = AnansiConfig.new(true) 
  c.start("#{RAILS_ROOT}/anansi/")
  c.crawl
END

  system "ruby ./script/runner '#{cmd}'"
end

desc "Runs the 2nd stage of the crawler"
task :anansi_parse do

  # TODO Remove "true" which indicates testing
  cmd = <<END
  p = AnansiParser.new(true) 
  p.start("#{RAILS_ROOT}/anansi")
  p.parse
END

  system "ruby ./script/runner '#{cmd}'"
end

desc "Check for email sent to post comments and photos"
task :check_email do
  
  cmd = <<END
  	puts "Checking for new email..."
  	puts "Started at: #{Time.now}"
  	puts ""
  	MailReader.check_email
  	puts "Ended at: #{Time.now}"
  	
END
  
  system "ruby ./script/runner '#{cmd}'"
end

desc "Send out emails about fan's favorite bands"
task :send_faves do
  
  cmd = <<END
  	puts "Sending fans email about favorite bands..."
  	puts "Started at: #{Time.now}"
  	puts ""
  	FavoritesMailer.do_favorites_updates
  	puts "Ended at: #{Time.now}"
END
  
  system "ruby ./script/runner '#{cmd}'"
end

desc "Send out show reminders to fans"
task :send_reminders do
  
  cmd = <<END
  	puts "Sending show reminders for fans..."
  	puts "Started at: #{Time.now}"
  	puts ""
  	RemindersMailer.do_show_reminders
  	puts "Ended at: #{Time.now}"
END
  
  system "ruby ./script/runner '#{cmd}'"
end

desc "Index the database into ferret"
task :update_index do
  cmd = <<END
    puts "Indexing the database..."
  	puts "Started at: #{Time.now}"
  	puts ""
  	Indexer.index_db
  	puts "Ended at: #{Time.now}"
END

  system "ruby ./script/runner '#{cmd}'"
end

desc "Clean out old sessions"
task :delete_old_sessions do

  # NOTE: Remember the "rake purge_sessions_table" task for deleting ALL sessions
  # It drops the table and recreates it
  #
  # Set to delete sessions older than 24 hours
  cmd = <<END
    puts "Deleting old sessions..."
  	puts "Started at: #{Time.now}"
  	puts ""
  	ActiveRecord::Base.connection.delete("DELETE FROM sessions WHERE updated_at < now() - 24*3600")
  	puts "Ended at: #{Time.now}"
END

  system "ruby ./script/runner '#{cmd}'"
end

desc "Creates the admin user"
task :create_admin do
  cmd = <<END
    puts "Creating admin user..."
  	puts "Started at: #{Time.now}"
  	puts ""
  	
  	fan = Fan.new
  	fan.name = "admin"
  	fan.contact_email = "help@tourb.us"
  	fan.confirmed = true
  	fan.superuser = true
  	fan.salt = "eaae1f87fbab40ffc2a9181fb2b05afc2e37639c"
  	# Remember that bit MM used to do?
  	fan.salted_password = "67f5767a8e29b5e70800ea602809cc0c24d97b35"
  	fan.confirmation_code = "35c9c08c79571afc41b54053a58728ccc6f9d92a"
  	fan.uuid = "1"
  	fan.save!
  	
  	puts "Ended at: #{Time.now}"
END

  system "ruby ./script/runner '#{cmd}'"
end


