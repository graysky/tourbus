require File.dirname(__FILE__) + '/../test_helper'

class ShowTest < Test::Unit::TestCase
  fixtures :shows

  def setup
    @show = Show.find(1)
  end

  def test_band
    assert_equal 1, @show.band.id
  end
end
