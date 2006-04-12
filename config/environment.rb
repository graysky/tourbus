# ** NOTE: REMEMBER THERE IS THE DEVELOPMENT ENVIRONMENT **
# Consider what changes applied here need to be made in the production environment too. 
#
# Be sure to restart your webserver when you modify this file.

# Uncomment below to force Rails into production mode
# (Use only when you can't set environment variables through your web/app server)
# ENV['RAILS_ENV'] = 'production'


# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Skip frameworks you're not going to use
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # Added the Anansi code
  config.load_paths += %W( #{RAILS_ROOT}/anansi/lib )
  #config.load_paths.each { |file| puts "#{file}" }

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake create_sessions_table')
  config.action_controller.session_store = :active_record_store

  # Enable page/fragment caching by setting a file-based store
  # (remember to create the caching directory and make it readable to the application)
  # config.action_controller.fragment_cache_store = :file_store, "#{RAILS_ROOT}/cache"

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # Use Active Record's schema dumper instead of SQL when creating the test database
  # (enables use of different database adapters for development and test environments)
  # config.active_record.schema_format = :ruby

  # See Rails::Configuration for more options
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Include your application configuration below
# Include your app's configuration here:

# Might preserve these settings for testing
#ActionMailer::Base.server_settings = {
#  :address=>'mail.mytourb.us',
#  :domain=>'mytourb.us',
#  :port=>'25',                    
#  :user_name=>'m1147528',
#  :password=>'noreply',
#  :authentication=>:login
#} 

ActionMailer::Base.server_settings = {
  :address=>'mail.tourb.us',
  :domain=>'tourb.us',
  :port=>'25',                    
  :user_name=>'robot+tourb.us',
  :password=>'bighit',
  :authentication=>:login
} 

# Options to control how RailsCron behaves, intervals in seconds.
# Increase the frequency of db-checking in dev mode
RailsCron.options = {
    :sleep => 30,
    :db_sleep => 60,
    :allow_concurrency => false
}

require 'rails_file_column'
require 'selective_timestamp'
require 'validations'
require 'upcoming_shows'
require 'chunkable'

# For UTF-8 handling
$KCODE = 'u'
require 'jcode'
