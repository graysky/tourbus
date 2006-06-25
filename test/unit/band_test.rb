require File.dirname(__FILE__) + '/../test_helper'

class BandTest < Test::Unit::TestCase
  fixtures :bands

  def setup
    @band = bands(:green_arrows)
  end

  # Test text converted to short names
  def test_name_to_shortname
    assert_equal "crisisbureau", Band.name_to_id("crisis bureau")
    assert_equal "crisis_bureau", Band.name_to_id("crisis_bureau")
    assert_equal "crisisbureau2000", Band.name_to_id("crisis bureau 2000")
    assert_equal "crisisbureau", Band.name_to_id("!crisis bureau*")
    assert_equal "crisis-bureau", Band.name_to_id("crisis-bureau")
    assert_equal "crisis.bureau", Band.name_to_id("crisis.bureau")
    assert_equal "crisisandbureau", Band.name_to_id("(crisis@&*bureau)")
    assert_equal "crisisbureau", Band.name_to_id("Crisis Bureau")
  end
end
