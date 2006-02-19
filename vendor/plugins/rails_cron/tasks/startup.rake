require 'active_support'

def sudo(cmd)
  ENV['RAILSCRON_SUDO'].blank? ? cmd : "sudo -u #{ENV['RAILSCRON_SUDO']} #{cmd}"
end

desc "Stars RailsCron on Windows in foreground. Stop with Ctrl-C"
task :cron_win do

  cmd = <<END
    puts "Starting RailsCron at #{Time.now}"
    RailsCron.start
END

  system "ruby ./script/runner '#{cmd}'"
end

desc "Starts RailsCron as a daemon"
task :cron_start do
  if `#{sudo "ps x | grep RailsCron | grep -v grep"}`.strip.blank?
    mode = ENV['RAILS_ENV'] || "development"
    puts `#{sudo "nohup ruby script/runner -e #{mode} \"RailsCron.start\" &> /dev/null &"}`
  else
    puts "RailsCron already started"
  end
end

desc "Starts RailsCron in the foreground"
task :cron_foreground do
  mode = ENV['RAILS_ENV'] || "development"
  puts `ruby script/runner -e #{mode} \"RailsCron.start\"`
end

desc "Signals RailsCron to stop when the current tasks are finished"
task :cron_stop do
  `#{sudo "ps x | grep RailsCron | grep -v grep | awk '{print $1}' | xargs kill -USR1"}`
end

desc "Kills RailsCron processes"
task :cron_kill do
  `#{sudo "ps x | grep RailsCron | grep -v grep | awk '{print $1}' | xargs kill -9"}`
end

desc "Kills and restarts RailsCron"
task :cron_restart => [:cron_kill, :wait_till_none, :cron_start] do
end

desc "Gracefully restarts RailsCron"
task :cron_graceful => [:cron_stop, :wait_till_none, :cron_start] do  
end

desc "Status of RailsCron"
task :cron_status do
  puts `#{sudo "ps x | grep RailsCron | grep -v grep"}`
end

task :wait_till_none do 
  until `#{sudo "ps x | grep RailsCron | grep -v grep"}`.strip.blank?
    sleep 1
  end
end
