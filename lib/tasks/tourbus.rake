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


desc "Send out show reminders"
task :send_reminders do
  
  cmd = <<END
  	puts "Sending show reminders..."
  	puts "Started at: #{Time.now}"
  	puts ""
  	RemindersMailer.do_show_reminders
  	puts "Ended at: #{Time.now}"
END
  
  system "ruby ./script/runner '#{cmd}'"
end

