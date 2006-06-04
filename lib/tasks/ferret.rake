# =============================================================================
# A set of rake tasks for dealing with ferret indices.
# FOR DEBUGGING AND DEVELOPMENT PURPOSES ONLY
# =============================================================================

desc "Re-index the entire database - uses the current RAILS_ENV for which DB to index."
task :reindex do
  cmd = <<END
    puts "Re-indexing bands..."
    Band.find(:all).each { |band| band.ferret_save }
    puts "Re-indexing venues..."
    Venue.find(:all).each { |venue| venue.ferret_save }
    puts "Re-indexing shows..."
    Show.find(:all).each { |show| show.ferret_save }
END
  
  system "ruby ./script/runner '#{cmd}'"
end

desc "Re-index only parts of the database - uses the current RAILS_ENV for which DB to index."
task :dev_reindex do
  cmd = <<END
    b = 200
    v = 200
    s = 200
    puts "Re-indexing some bands..."
    Band.find(:all).each { |band| b = b - 1; band.ferret_save if b > 0 }
    puts "Re-indexing some venues..."
    Venue.find(:all).each { |venue| v = v - 1; venue.ferret_save if v > 0}
    puts "Re-indexing some shows..."
    Show.find(:all).each { |show| s = s - 1; show.ferret_save if s > 0 }
END
  
  system "ruby ./script/runner '#{cmd}'"
end

desc "Completely destroys the ferret index"
task :destroy_index do
  Dir.glob("db/tb.index/**/*") do |file|
    if File.file?(file) and File.basename(file) != "readme.txt"
      FileUtils.rm(file)
    end
  end
end
