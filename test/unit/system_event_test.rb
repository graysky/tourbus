require File.dirname(__FILE__) + '/../test_helper'

class SystemEventTest < Test::Unit::TestCase
  fixtures :system_events

  def test_create
    event = SystemEvent.create("name", SystemEvent::FAVORITES, SystemEvent::INFO, "testing")
    assert_equal "name", event.name
    assert_equal SystemEvent::FAVORITES, event.area
    assert_equal SystemEvent::INFO, event.level
    assert_equal "testing", event.description
    assert event.created_at
    
    event = SystemEvent.create("name", SystemEvent::FAVORITES, SystemEvent::INFO)
    assert event.description.nil?
    
    event = SystemEvent.info("1", "fs", "sf")
    assert_equal SystemEvent::INFO, event.level
    
    event = SystemEvent.warning("1", "fs")
    assert_equal SystemEvent::WARNING, event.level
    
    event = SystemEvent.error("1", "fs", "sf")
    assert_equal SystemEvent::ERROR, event.level
  end
end
