# =============================================================================
# A set of rake tasks for invoking the SwitchTower automation utility.
# =============================================================================

# Invoke the given actions via SwitchTower
def switchtower_invoke(*actions)
  begin
    require 'rubygems'
  rescue LoadError
    # no rubygems to load, so we fail silently
  end

  require 'switchtower/cli'

  args = %w[-vvvvv -r config/deploy]
  args.concat(actions.map { |act| ["-a", act.to_s] }.flatten)
  SwitchTower::CLI.new(args).execute!
end

desc "Push the latest revision to staging server"
task :deploy_stage do

  ENV['STAGE'] = "dev"
  switchtower_invoke :deploy
end

desc "Push the latest revision to production server"
task :deploy do
  switchtower_invoke :deploy
end

desc "Rollback to the release before the current release in staging"
task :rollback_stage do
  ENV['STAGE'] = "dev"
  switchtower_invoke :rollback
end

desc "Rollback to the release before the current release in production"
task :rollback do
  switchtower_invoke :rollback
end

desc "Describe the differences between HEAD and the last production release"
task :diff_from_last_deploy do
  switchtower_invoke :diff_from_last_deploy
end

desc "Enumerate all available deployment tasks"
task :show_deploy_tasks do
  switchtower_invoke :show_tasks
end

desc "Update the currently released version of the software directly via an SCM update operation"
task :update_current do
  switchtower_invoke :update_current
end

desc "Execute a specific action using switchtower"
task :remote_exec_stage do
  unless ENV['ACTION']
    raise "Please specify an action (or comma separated list of actions) via the ACTION environment variable"
  end

  ENV['STAGE'] = "dev"
  actions = ENV['ACTION'].split(",")
  switchtower_invoke(*actions)
end

desc "Execute a specific action using switchtower"
task :remote_exec do
  unless ENV['ACTION']
    raise "Please specify an action (or comma separated list of actions) via the ACTION environment variable"
  end

  actions = ENV['ACTION'].split(",")
  switchtower_invoke(*actions)
end
