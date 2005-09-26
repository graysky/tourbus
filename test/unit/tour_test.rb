require File.dirname(__FILE__) + '/../test_helper'

class TourTest < Test::Unit::TestCase
  fixtures :tours

  def setup
    @tour = Tour.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Tour,  @tour
  end
end
