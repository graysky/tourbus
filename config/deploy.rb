# This defines a deployment "recipe" that you can feed to switchtower:
# http://manuals.rubyonrails.com/read/book/17
#
# =============================================================================
# USAGE
# =============================================================================
# This is for deploying to LiquidWeb. It is configured for:
# DEPRECATED tourbus.figureten.com (staging)
# tourb.us (real production)
#
# Tips: 
# "rake --tasks" will list all available tasks
# "rake show_deploy_tasks" will list all switchtower tasks
#
# Typical usage:
# Push out full new release, run migration, etc:
# rake deploy
#
# Push out new code from SVN:
# rake update_current
#
# Rollback to previous release:
# rake rollback
# 
# Other useful tasks:
#
# rollback - rollback to last deployment
# 
# spinner - first start FCGI processes using spawner ("rake remote:exec ACTION=spinner")
# cleanup - deletes >5 deployments (needs "rake remote:exec ACTION=cleanup")
# 
# reaper - kill the FCGI processes using reaper
#
# Use this to run any non-rake switchtower tasks (NOT CURRENTLY IN USE):
# rake remote_exec [STAGE=dev] ACTION=<action-name>
#
# To deploy to staging enviroment, use "_stage" commands, namely:
# rake deploy_stage
# rake rollback_stage
#
# Or, set the "STAGE" env to "dev", like:
# rake remote_exec STAGE=dev ACTION=<action-name>
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
set :repository, "svn://downtree.com/tourbus/tourbus/branches/tourbus-production"

set :use_sudo, true

set :domain, "tourb.us" # 208.75.84.28
role :web, domain
role :app, domain
role :db,  domain, :primary => true

# Check for ENV to determine which type of deployment. 
# 
if ENV['STAGE'] == "dev" or ENV['STAGE'] == "development"
  # ---DEPRECATED---
  # Staging deployment to tourbus.figureten.com
  #
  set :use_sudo, true
  #set :stage, "stage"
  # Need user with Bash shell on remote machine with right perms
  # This account has the normal password
  set :user, "lighty"
  
  # Full path on the remote box
  set :deploy_to, "/var/www/apps/#{application}"
  # Roles
  set :domain, "tourb.us"
  role :web, domain
  role :app, domain
  role :db,  domain, :primary => true

  ssh_options[:keys] = %w(/home/gary/.ssh/id_rsa)

else
  # Production deployment to tourb.us
  #
  set :stage, "production"
  # Password is funny Dave C. skit
	  set :user, "lighty"
  set :user, "lighty"
  set :deploy_to, "/var/www/apps/#{application}"
  # Roles

end

# *************
# DEPREC OPTIONS (http://deprec.rubyforge.org)
# 
# =============================================================================
# APACHE OPTIONS
# =============================================================================
set :apache_server_name, domain
# set :apache_server_aliases, %w{alias1 alias2}
#set :apache_default_vhost, true # force use of apache_default_vhost_config
#set :apache_default_vhost_conf, "/etc/httpd/conf/default.conf"
set :apache_conf, "/usr/local/apache2/conf/apps/#{application}.conf"
set :apache_ctl, "/etc/init.d/httpd"
set :apache_proxy_port, 8000
set :apache_proxy_servers, 4
set :apache_proxy_address, "127.0.0.1"
# set :apache_ssl_enabled, false
# set :apache_ssl_ip, "127.0.0.1"
# set :apache_ssl_forward_all, false
# set :apache_ssl_chainfile, false

# =============================================================================
# MONGREL OPTIONS
# =============================================================================
set :mongrel_servers, apache_proxy_servers
set :mongrel_port, apache_proxy_port
set :mongrel_address, apache_proxy_address
set :mongrel_environment, "production"
set :mongrel_config, "/etc/mongrel_cluster/#{application}.conf"
set :mongrel_user, "lighty"
set :mongrel_group, "users"
#
# **************

# =============================================================================
# TASKS
# =============================================================================

desc <<-DESC
Task that updates the code, fixes the symlink, migrates the db and restarts the
application servers.
DESC
task :deploy do
  transaction do
    update_code

    # Push around the config files    
    push_db_file
    push_env_file
    
    symlink
    
    # This must come *after* symlinking
    # to do the "current" migration
    migrate
  end

  restart # Restart FCGI procs
  
end

desc "Setup task that to run before the first deployment for TB-specific setup"
task :after_setup do
  # Make directories that are shared between releases for images,
  # ferret index and anansi data
  run <<-CMD
    mkdir -p -m 777 #{shared_path}/tb.index #{shared_path}/public #{shared_path}/anansi &&
    mkdir -p -m 777 #{shared_path}/tb.index/band #{shared_path}/tb.index/venue &&
    mkdir -p -m 777 #{shared_path}/tb.index/show #{shared_path}/tb.index/fan &&
    mkdir -p -m 777 #{shared_path}/public/band #{shared_path}/public/venue &&
    mkdir -p -m 777 #{shared_path}/public/show #{shared_path}/public/fan &&
    mkdir -p -m 777 #{shared_path}/anansi/data
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
    ln -nfs #{shared_path}/tb.index/fan #{release_path}/db/tb.index/fan &&
    ln -nfs #{shared_path}/anansi/data #{release_path}/anansi/data
    CMD
end

desc "Restart FCGI after update current code"
task :after_update_current do

  # Do any DB migrations
  migrate
  
  # Restart FCGI procs
  restart
end

desc "Restart the mongrel cluster"
task :restart, :roles => :app do
  #send(run_method, "cd #{deploy_to}/#{current_dir} && mongrel_rails cluster::restart")
  run <<-CMD
      cd #{deploy_to}/#{current_dir} && mongrel_rails cluster::restart
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

desc "Start the FCGI processes using spinner"
task :spinner, :roles => :app do
  # Attempt to spin it every 30 seconds as a daemon
  # NOTE - this controls how many FCGI procs to start (must match lighty config)
  run <<-CMD
    #{current_path}/script/process/spinner -d -i 30 -c '#{current_path}/script/process/spawner -p 8000 -i 2'
  CMD
end

desc "Start the FCGI processes using spinner"
task :spawner, :roles => :app do
  # NOTE - USE SPINNER INSTEAD
  # Attempt to spin it every 30 seconds as a daemon starting on port 8000 (must match lighty config)
  # NOTE - this controls how many FCGI procs to start
  run <<-CMD
    #{current_path}/script/process/spawner -p 8000 -i 2 -r 30 &
  CMD
end

desc "Stops the FCGI processes using reaper"
task :reaper, :roles => :app do
  # Attempt to stop the FCGI procs
  run <<-CMD
    #{current_path}/script/process/reaper -a kill
  CMD
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
