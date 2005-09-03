require File.dirname(__FILE__) + '/../test_helper'

class VenueTest < Test::Unit::TestCase
  fixtures :venues

  def setup
    @venue = Venue.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Venue,  @venue
  end
end
