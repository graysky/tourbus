# =============================================================================
# A set of rake tasks for dealing with tourbus actions
# =============================================================================


desc "Send out emails about fan's favorite bands"
task :send_faves do
  
  cmd = <<END
  	puts "Sending fans email about favorite bands..."
  	FavoritesMailer.do_favorites_updates
END
  
  system "ruby ./script/runner '#{cmd}'"
end
