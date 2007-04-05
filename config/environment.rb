# ** NOTE: REMEMBER THERE IS THE DEVELOPMENT ENVIRONMENT **
# Consider what changes applied here need to be made in the production environment too. 
#
# Be sure to restart your webserver when you modify this file.

# Uncomment below to force Rails into production mode
# (Use only when you can't set environment variables through your web/app server)
# ENV['RAILS_ENV'] = 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
#RAILS_GEM_VERSION = '1.1.6'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require "log4r"

Rails::Initializer.run do |config|
  # Skip frameworks you're not going to use
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # Added the Anansi code
  config.load_paths += %W( #{RAILS_ROOT}/ataturk/lib #{RAILS_ROOT}/anansi/lib #{RAILS_ROOT}/song_crawler #{RAILS_ROOT}/song_crawler/server #{RAILS_ROOT}/song_crawler/client)
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

ActiveSupport::Deprecation.silenced = true

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
  :address=>'smtp1.dnsmadeeasy.com',
  :domain=>'tourb.us',
  #:port=>'25', # Default, blocked by RCN
  :port=>'5521',                    
  :user_name=>'robot+tourb.us',
  :password=>'bighit',
  :authentication=>:login
} 

# Log entries in a secondary database...
LogEntry.establish_connection(
     :adapter  => "mysql",
     :host     => "127.0.0.1",
     :username => "root",
     :password => "bighit",
     :database => "tourbus_stats"
   )

ExceptionNotifier.exception_recipients = %w(feedback@tourb.us)
ExceptionNotifier.sender_address = %("tourb.us robot" <robot@tourb.us>)
ExceptionNotifier.email_prefix = "[tourb.us]"

# Create component-specific loggers here
TURK_LOGGER = Log4r::Logger.new("Turk")
formatter = Log4r::PatternFormatter.new(:pattern => "[%l] %d - %m")
Log4r::RollingFileOutputter.new('turk_log',
                        :filename => "#{RAILS_ROOT}/log/turk.log",
                        :trunc => false,
                        :count => 10,
                        :maxtime => 24.hours,
                        :formatter => formatter,
                        :level => Log4r::DEBUG)
TURK_LOGGER.add('turk_log')

OFFLINE_LOGGER = Log4r::Logger.new("offline")
formatter = Log4r::PatternFormatter.new(:pattern => "[%l] %d - %m")
Log4r::RollingFileOutputter.new('offline_log',
                        :filename => "#{RAILS_ROOT}/log/offline.log",
                        :trunc => false,
                        :count => 10,
                        :maxtime => 24.hours,
                        :formatter => formatter,
                        :level => Log4r::DEBUG)
OFFLINE_LOGGER.add('offline_log')

require 'rails_file_column'
require 'selective_timestamp'
require 'validations'
require 'chunkable'
require 'array'

# For UTF-8 handling
$KCODE = 'u'
require 'jcode'
