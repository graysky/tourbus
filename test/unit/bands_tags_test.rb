require File.dirname(__FILE__) + '/../test_helper'

# Test band tagging
class BandsTagsTest < Test::Unit::TestCase
  fixtures :bands, :tags, :bands_tags

  def setup
    @endgame = Band.find(1)
    @cb = Band.find(2)
  end

  def test_tags_size
    assert_equal 1, @endgame.tags.size
  end
  
  def test_add_new_tag
    tag = Tag.new(:name => "TEST1")
    @endgame.tags << tag
    @endgame.save
    
    assert_equal 2, @endgame.tags.size
    assert_equal 1, tag.bands.size
  end
end
