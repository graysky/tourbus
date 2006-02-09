# This defines a deployment "recipe" that you can feed to switchtower:
# http://manuals.rubyonrails.com/read/book/17
#
# =============================================================================
# USAGE
# =============================================================================
# This is for deploying to LiquidWeb. It is configured for:
# OLD - tourbus.figureten.com (staging)
# tourb.us (real production)
#
# Typical usage ("rake --tasks" will list all tasks)
# rake deploy
#
# Push out new code from SVN:
# rake update_current
#
# Use this to run non-rake switchtower tasks:
# rake remote_exec [STAGE=dev] ACTION=<action-name>
#
# To deploy to staging enviroment, use "_stage" commands, namely:
# rake deploy_stage
# rake rollback_stage
#
# Or, set the "STAGE" env to "dev". The normal tasks run against the live
# production environment.
# 
# To start a deployment calling switchtower directly:
# switchtower -vvvv -r config/deploy -a [code_deploy | deploy | update_code ]
#
# Note: For when we just want to push new code, we can use the "update_current" task
# which just fetches the latest code. Good for when pushing out small changes, or for our testing.
#
# =============================================================================
# VARIABLES and ROLES
# =============================================================================
#
# App name
set :application, "tourbus"

# SVN repo. Switchtower needs a couple things:
# - Deploys only what is in your local SVN working copy (not HEAD)
# - Assumes anon. read access.
# - Requires that the local copy has "svn" in the path.
set :repository, "svn://graysky.dyndns.org/svn/tourbus/trunk/tourbus"

# Don't use sudo for restarting lighty.
set :restart_via, :run

# Check for ENV to determine which type of deployment. 
# 
if ENV['STAGE'] == "dev" or ENV['STAGE'] == "development"
  # Staging deployment to tourbus.figureten.com
  #
  set :stage, "stage"
  # Need user with Bash shell on remote machine with right perms
  # This account has the normal password
  set :user, "figureten"
  
  # Full path on the remote box
  set :deploy_to, "/home/.kasian/figureten/tourbus.figureten.com/#{application}"
  # Roles
  role :web, "tourbus.figureten.com"
  role :app, "tourbus.figureten.com"
  role :db,  "tourbus.figureten.com"
  
else
  # Production deployment to mytourb.us
  #
  set :stage, "production"
  # Password is funny Dave C. skit
  set :user, "lighty"
  set :deploy_to, "/var/www/rails/#{application}"
  # Roles
  role :web, "tourb.us"
  role :app, "tourb.us"
  role :db,  "tourb.us"
end

# =============================================================================
# TASKS
# =============================================================================

desc "Setup task that to run before the first deployment for TB-specific setup"
task :after_setup do
  # Make directories that are shared between releases for images
  # and the ferret index
  run <<-CMD
    mkdir -p -m 777 #{shared_path}/tb.index #{shared_path}/public &&
    mkdir -p -m 777 #{shared_path}/tb.index/band #{shared_path}/tb.index/venue &&
    mkdir -p -m 777 #{shared_path}/tb.index/show #{shared_path}/tb.index/fan &&
    mkdir -p -m 777 #{shared_path}/public/band #{shared_path}/public/venue &&
    mkdir -p -m 777 #{shared_path}/public/show #{shared_path}/public/fan
  CMD
end

desc "Create symlinks for TB-specific directories for images and ferret index"
task :after_symlink do
  # Create TB-specific symlinks for ferret index and images
  run <<-CMD
    ln -nfs #{shared_path}/public/band #{release_path}/public/band &&
    ln -nfs #{shared_path}/public/show #{release_path}/public/show &&
    ln -nfs #{shared_path}/public/venue #{release_path}/public/venue &&
    ln -nfs #{shared_path}/public/fan #{release_path}/public/fan &&
    rm -rf #{release_path}/db/tb.index/band #{release_path}/db/tb.index/show &&
    rm -rf #{release_path}/db/tb.index/venue #{release_path}/db/tb.index/fan &&
    ln -nfs #{shared_path}/tb.index/band #{release_path}/db/tb.index/band &&
    ln -nfs #{shared_path}/tb.index/show #{release_path}/db/tb.index/show &&
    ln -nfs #{shared_path}/tb.index/venue #{release_path}/db/tb.index/venue &&
    ln -nfs #{shared_path}/tb.index/fan #{release_path}/db/tb.index/fan
    CMD
end

desc "Restart FCGI after update current code"
task :after_update_current do
  # Restart FCGI procs
  restart
end

desc "Freeze the other gems using rake. - NEEDED??"
task :freeze_other_gems do

    # Execute rake command to freeze Ferret gem. 
    # Need to source bash_profile to set up correct GEM_PATH. 
    # Assumes the bash_profile does that, like this:
    # export GEM_HOME=$HOME/gems
    # export GEM_PATH=/usr/lib/ruby/gems/1.8:$GEM_HOME
    run <<-CMD
      cd #{release_path} && source ~/.bash_profile && rake freeze_other_gems
    CMD
end

desc "Push the right version of databse.yml."
task :push_db_file do

  # For stage deployments, move the database.yml for staging
  if stage == "stage"
  
    # Need to delete before pushing the new one, or it just cats it to the top
    delete("#{release_path}/config/database.yml")
    
    put(File.read('config/database_stage.yml'),
        "#{release_path}/config/database.yml",
        :mode => 0444)
  end
end

desc "Push the right version of environment.rb."
task :push_env_file do

  # For deployments, move the environment_prod.rb into right place
  
  # Need to delete before pushing the new one, or it just cats it to the top
  delete("#{release_path}/config/environment.rb")
    
  put(File.read('config/environment_production.rb'),
      "#{release_path}/config/environment.rb",
      :mode => 0666)
end

desc "Code deploy. Get the new code and adjusts symlinks"
task :code_deploy do
  transaction do

    update_code
    
    push_db_file
    
    push_env_file
    
    # Don't need to freeze on tourb.us
    ##freeze_ferret
    
    migrate
    
    ## disable_web
    symlink
    
    ## TB-specific symlinks
    tb_symlink
  end

  # restart
  # enable_web
end

desc <<-DESC
A macro-task that updates the code, fixes the symlink, and restarts the
application servers.
DESC
task :deploy do
  transaction do
    update_code
    
    push_db_file
    push_env_file
    
    # Don't need to freeze on tourb.us
    ##freeze_other_gems
    
    symlink
  end

  restart
end

# Tasks may take advantage of several different helper methods to interact
# with the remote server(s). These are:
#
# * run(command, options={}, &block): execute the given command on all servers
#   associated with the current task, in parallel. The block, if given, should
#   accept three parameters: the communication channel, a symbol identifying the
#   type of stream (:err or :out), and the data. The block is invoked for all
#   output from the command, allowing you to inspect output and act
#   accordingly.
# * sudo(command, options={}, &block): same as run, but it executes the command
#   via sudo.
# * delete(path, options={}): deletes the given file or directory from all
#   associated servers. If :recursive => true is given in the options, the
#   delete uses "rm -rf" instead of "rm -f".
# * put(buffer, path, options={}): creates or overwrites a file at "path" on
#   all associated servers, populating it with the contents of "buffer". You
#   can specify :mode as an integer value, which will be used to set the mode
#   on the file.
# * render(template, options={}) or render(options={}): renders the given
#   template and returns a string. Alternatively, if the :template key is given,
#   it will be treated as the contents of the template to render. Any other keys
#   are treated as local variables, which are made available to the (ERb)
#   template.

#desc "Demonstrates the various helper methods available to recipes."
#task :helper_demo do
#  # "setup" is a standard task which sets up the directory structure on the
#  # remote servers. It is a good idea to run the "setup" task at least once
#  # at the beginning of your app's lifetime (it is non-destructive).
#  setup
#
#  buffer = render("maintenance.rhtml", :deadline => ENV['UNTIL'])
#  put buffer, "#{shared_path}/system/maintenance.html", :mode => 0644
#  sudo "killall -USR1 dispatch.fcgi"
#  run "#{release_path}/script/spin"
#  delete "#{shared_path}/system/maintenance.html"
#end

#desc <<DESC
#An imaginary backup task. (Execute the 'show_tasks' task to display all
#available tasks.)
#DESC
#task :backup, :roles => :db, :only => { :primary => true } do
#  # the on_rollback handler is only executed if this task is executed within
#  # a transaction (see below), AND it or a subsequent task fails.
#  on_rollback { delete "/tmp/dump.sql" }
#
#  run "mysqldump -u theuser -p thedatabase > /tmp/dump.sql" do |ch, stream, out|
#    ch.send_data "thepassword\n" if out =~ /^Enter password:/
#  end
#end

# You can use "transaction" to indicate that if any of the tasks within it fail,
# all should be rolled back (for each task that specifies an on_rollback
# handler).
desc "A task demonstrating the use of transactions."
task :long_deploy do
  transaction do
    update_code
    disable_web
    symlink
    migrate
  end

  restart
  enable_web
end

#desc "Restart the FCGI processes on the app server as a regular user."
#task :restart, :roles => :app do
#  # From Shovel deploy recipe
#  run "killall -USR1 dispatch.fcgi"
#  #run "#{current_path}/script/process/reaper"
#end
