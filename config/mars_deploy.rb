# This defines a deployment "recipe" that you can feed to switchtower
# (http://manuals.rubyonrails.com/read/book/17). It allows you to automate
# (among other things) the deployment of your application.

# =============================================================================
# VARIABLES
# =============================================================================
# You must always specify the application and repository for every recipe. The
# repository must be the URL of the repository you want this recipe to
# correspond to. The deploy_to path must be the path on each machine that will
# form the root of the application path.

# ======
# This is specific to Mike's linux box (mars) but can serve as a template
# for other machines
# ======
#
# To start a deployment use:
# switchtower -vvvv -r config/mars_deploy -a [dirty_deploy | deploy | update_code ]
#
# NOTE: Using the rake switchtower tasks doesn't seem to work properly. I
# think I saw mention on Jamis Buck's blog that the next ST rel fixes this

# App name
set :application, "tourbus"

# Need user with bash shell on remote machine with right perms
set :user, "deployer"        # defaults to the currently logged in user

set :scm, :cvs               # defaults to :subversion

# CVS repo, including the user to login as. Might require a single login as that user to set remote cvspass
set :repository, ":pserver:deployer@graysky.dyndns.org:/home/repos/"

# Path on the remote box
set :deploy_to, "/var/www/html/rails/#{application}"

# Complained without this
set :local, "C:\\workspaces\\acadia1\\tourbus" 

# Part of a hack to the ST CVS code to use this CVS method for the local connection
# (i.e. before deployment). By default cvs picks up the CVSROOT from the tourbus/CVS/Root
# file. I think that file could be changed to use a line like this instead. Or,
# {RUBY_HOME}\ruby\lib\ruby\gems\1.8\gems\switchtower-0.10.0\lib\switchtower\scm\cvs.rb
# Line 68 can be updated to this:
# `cd #{path || "."} && cvs -d #{configuration.localrepo} -q log -N -rHEAD`
set :localrepo, ":pserver:champion@graysky.dyndns.org:/home/repos/"

# Should already be in the path. Set with right value if it is not.
#set :cvs, "/usr/bin/cvs"

# =============================================================================
# ROLES
# =============================================================================
# You can define any number of roles, each of which contains any number of
# machines. Roles might include such things as :web, or :app, or :db, defining
# what the purpose of each machine is. You can also specify options that can
# be used to single out a specific subset of boxes in a particular role, like
# :primary => true.

role :web, "graysky.dyndns.org"
role :app, "graysky.dyndns.org"
role :db,  "graysky.dyndns.org"

# =============================================================================
# TASKS
# =============================================================================

desc "Quick and Dirty deploy -- MGC"
task :dirty_deploy do
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
