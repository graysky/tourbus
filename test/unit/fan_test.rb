require File.dirname(__FILE__) + '/../test_helper'

class FanTest < Test::Unit::TestCase
  fixtures :fans

  def setup
    @fan = fans(:gary)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Fan,  @fan
  end
  
  def test_simple
    assert_equal "gary", @fan.name
  end
end
