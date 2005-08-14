require File.dirname(__FILE__) + '/../test_helper'

class BandTest < Test::Unit::TestCase
  fixtures :bands

  def setup
    @band = Band.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Band,  @band
  end
end
