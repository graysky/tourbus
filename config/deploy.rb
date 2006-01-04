# This defines a deployment "recipe" that you can feed to switchtower
# (http://manuals.rubyonrails.com/read/book/17). It allows you to automate
# (among other things) the deployment of your application.

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
# rake remote_exec_stage ACTION=<action-name>
# 
# Or, set the "STAGE" env to "stage". The normal tasks run against the live
# production environment.
# 
# To start a deployment calling switchtower directly:
# switchtower -vvvv -r config/deploy -a [code_deploy | deploy | update_code ]
#
# =============================================================================
# VARIABLES and ROLES
# =============================================================================
#
# App name
set :application, "tourbus"

# Set to CVS - default to svn
set :scm, :cvs           

# Part of a hack to the ST CVS code to use this CVS method for the local connection
# (i.e. before deployment). By default cvs picks up the CVSROOT from the tourbus/CVS/Root
# file. I updated this file to get it stop whining, although I think it works without this.
# {RUBY_HOME}\ruby\lib\ruby\gems\1.8\gems\switchtower-0.10.0\lib\switchtower\scm\cvs.rb
# Line 68 can be updated to this:
# `cd #{path || "."} && cvs -d #{configuration.localrepo} -q log -N -rHEAD`
set :localrepo, ":pserver:champion@graysky.dyndns.org:/home/repos/"

# CVS repo, including the user to login as. 
# Might require a single login as that user to set remote cvspass
set :repository, ":pserver:deployer@graysky.dyndns.org:/home/repos/"

# Complained without this - don't know if it is truly needed
set :local, "C:\\workspaces\\acadia1\\tourbus" 

# Check for ENV to determine which type of deployment. 
# 
if ENV['STAGE'] == "stage"
  # Staging deployment to tourbus.figureten.com
  #
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

desc "Quick and Dirty deploy. Just pushs code and adjusts symlinks -- MGC"
task :code_deploy do
  transaction do
    update_code
    ## disable_web
    symlink
    ## migrate
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
