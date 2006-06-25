require File.dirname(__FILE__) + '/../test_helper'

# Test the Band model
class BandTest < Test::Unit::TestCase

  def setup
    @ga = bands(:green_arrows)
    @bf = bands(:blood_feathers)
  end
  
  def test_uuid
    @bf.uuid = @ga.uuid
    assert(!@bf.valid?, "Invalid UUID")
    
    @bf.uuid = UUID.random_create.to_s
    assert(@bf.valid?, "Invalid UUID")
  end
  
  def test_short_name
    @bf.short_name = @ga.short_name
    assert(!@bf.valid?, "Short name already used")
    
    @bf.short_name = "fan"
    assert(!@bf.valid?, "Can't use name of route")

    @bf.short_name = "admin"
    assert(!@bf.valid?, "Can't use name of route")
  end
  
  def test_password
    @ga.new_password = true
    @ga.password = "sux"
    assert(!@ga.valid?, "Password invalid")
    
    @ga.password = "balls"
    assert(@ga.valid?, "Password invalid")
    
    @ga.password = nil
    assert(!@ga.valid?, "Password invalid")
    
    @ga.password = "good_password"
    @ga.password_confirmation = "good_password"
    assert(@ga.valid?, "Passwords must match")
    
    @ga.password = "good_password"
    @ga.password_confirmation = "bad_password"
    assert(!@ga.valid?, "Passwords must match")
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
