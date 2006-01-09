# This defines a deployment "recipe" that you can feed to switchtower:
# http://manuals.rubyonrails.com/read/book/17
#
# =============================================================================
# USAGE
# =============================================================================
# This is for deploying to Dreamhost. It is configured for:
# tourbus.figureten.com (staging)
# mytourb.us (real production)
#
# To deploy to staging enviroment, use "_stage" commands, namely:
# rake deploy_stage
# rake rollback_stage
#
# Use this to run non-rake switchtower tasks:
# rake remote_exec STAGE=dev ACTION=<action-name>
# 
# Or, set the "STAGE" env to "dev". The normal tasks run against the live
# production environment.
# 
# To start a deployment calling switchtower directly:
# switchtower -vvvv -r config/deploy -a [code_deploy | deploy | update_code ]
#
# Note: For when we just want to push new code, we can use the "update_current" task
# which just fetches the latest code. Good for when pushing out small changes, or for our testing.
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

# We don't have sudo permissions on dreamhost - should we use "run" instead?
# set :restart_via, :run

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
  set :user, "downtree"
  set :deploy_to, "/home/.jazzmen/downtree/mytourb.us/#{application}"
  # Roles
  role :web, "mytourb.us"
  role :app, "mytourb.us"
  role :db,  "mytourb.us"
end


# =============================================================================
# TASKS
# =============================================================================

desc "Freeze the Ferret gem using rake."
task :freeze_ferret do

    # Execute rake command to freeze Ferret gem. 
    # Need to source bash_profile to set up correct GEM_PATH. 
    # Assumes the bash_profile does that.
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
    
    put(File.read('config/stage_database.yml'),
        "#{release_path}/config/database.yml",
        :mode => 0444)
  
  end

end

desc "Code deploy. Just push the new code and adjusts symlinks"
task :code_deploy do
  transaction do

    update_code
    
    push_db_file
    
    freeze_ferret
    
    ## migrate
    ## disable_web
    symlink
  end

  # restart
  # enable_web
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

desc "Demonstrates the various helper methods available to recipes."
task :helper_demo do
  # "setup" is a standard task which sets up the directory structure on the
  # remote servers. It is a good idea to run the "setup" task at least once
  # at the beginning of your app's lifetime (it is non-destructive).
  setup

  buffer = render("maintenance.rhtml", :deadline => ENV['UNTIL'])
  put buffer, "#{shared_path}/system/maintenance.html", :mode => 0644
  sudo "killall -USR1 dispatch.fcgi"
  run "#{release_path}/script/spin"
  delete "#{shared_path}/system/maintenance.html"
end

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
