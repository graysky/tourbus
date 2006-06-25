require File.dirname(__FILE__) + '/../test_helper'

class TagTest < Test::Unit::TestCase
  fixtures :tags

  def setup
    @punk = tags(:punk)
  end

  # Replace this with your real tests.
  def test_valid
    unnamed_tag = Tag.new
    unnamed_tag.name = nil
    assert(!unnamed_tag.valid?, "Invalid tag")
  
    dup_tag = Tag.new
    dup_tag.name = "punk"
    assert(!dup_tag.valid?, "Invalid tag")
  end
end
