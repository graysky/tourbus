require File.dirname(__FILE__) + '/../test_helper'

class BandTest < Test::Unit::TestCase
  fixtures :bands

  def setup
    @band = Band.find(1)
  end

  def test_add_tag
    tag = Tag.new(:name => "xxx")
    @band.tags << tag
    @band.save
    assert_equal 1, @band.tags.size
    
  end
end
