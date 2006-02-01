# =============================================================================
# A set of rake tasks for dealing with tourbus actions
# =============================================================================

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

desc "Creates the admin user"
task :create_admin do
  cmd = <<END
    puts "Creating admin user..."
  	puts "Started at: #{Time.now}"
  	puts ""
  	
  	fan = Fan.new
  	fan.name = "admin"
  	# FIXME real email addr
  	fan.contact_email = "info@mytourb.us"
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


