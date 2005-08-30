require File.dirname(__FILE__) + '/../test_helper'

class BandTest < Test::Unit::TestCase
  fixtures :bands, :shows

  def setup
    @band = Band.find(1)
  end

  def test_add_tag
    tag = Tag.new(:name => "xxx")
    @band.tags << tag
    @band.save
    assert_equal 1, @band.tags.size
    
  end
  
  def test_shows
    assert_equal 2, @band.shows.size
    
    show = Show.new(:venue => "test", :zipcode => "01271", :date => Time.now)
    @band.shows << show
    @band.save
    assert_equal 3, @band.shows.size
  end
  
  def test_name_to_id
    assert_equal "crisisbureau", Band.name_to_id("crisis bureau")
    assert_equal "crisis_bureau", Band.name_to_id("crisis_bureau")
    assert_equal "crisisbureau2000", Band.name_to_id("crisis bureau 2000")
    assert_equal "crisisbureau", Band.name_to_id("!crisis bureau*")
    assert_equal "crisis-bureau", Band.name_to_id("crisis-bureau")
    assert_equal "crisis.bureau", Band.name_to_id("crisis.bureau")
    assert_equal "crisisbureau", Band.name_to_id("(crisis@&*bureau)")
  end
end
