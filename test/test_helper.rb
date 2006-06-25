ENV["RAILS_ENV"] = "test"

# Expand the path to environment so that Ruby does not load it multiple times
# File.expand_path can be removed if Ruby 1.9 is in use.
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'application'

require 'test/unit'
require 'active_record/fixtures'
require 'action_controller/test_process'
require 'action_web_service/test_invoke'
require 'breakpoint'

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + "/fixtures/"

module FixtureLoader
  def self.included(base)
    base.class_eval do
      fixtures :shows, :fans, :fans_shows, :bands, :bands_fans, :zip_codes, :venues
    end
  end
end

class Test::Unit::TestCase
  # Turn these on to use transactional fixtures with table_name(:fixture_name) instantiation of fixtures
  # self.use_transactional_fixtures = true
  # self.use_instantiated_fixtures  = false

  include FixtureLoader

  def create_fixtures(*table_names)
    Fixtures.create_fixtures(File.dirname(__FILE__) + "/fixtures", table_names)
  end

  # Add more helper methods to be used by ll tests here...
  def new_fan(name = 'dude')
    Fan.create_test_fan(name)
  end
end

# We just ignore foreigh key checks so that we can delete fixtures without worrying
ActiveRecord::Base.connection.update('SET FOREIGN_KEY_CHECKS = 0')