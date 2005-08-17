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
    @endgame.save()
    
    assert_equal 2, @endgame.tags.size
    assert_equal 1, tag.bands.size
  end
   
  def test_find_all_with_count
    tags = Tag.find_all_with_count
    assert_equal 1, tags.size
    assert_equal 1, tags[0].count
    
    # Add another tag to endgame
    tag = Tag.new(:name => "TEST1")
    @endgame.tags << tag
    @endgame.save
    tags = Tag.find_all_with_count
    assert_equal 2, tags.size
    assert_equal 1, tags[0].count
    
    # Add the new tag to cb
    @cb.tags << tag
    @cb.save
    tags = Tag.find_all_with_count
    assert_equal 2, tags.size
    assert_equal 2, tags[0].count
    assert_equal "TEST1", tags[0].name
  end
end