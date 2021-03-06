require 'abstract_unit'
require 'fixtures/entry'

class RMagickViewOnlyTest < Test::Unit::TestCase
  include FileColumnHelper

  def setup
    Entry.file_column :image
    @request = RequestMock.new
  end

  def teardown
    FileUtils.rm_rf File.dirname(__FILE__)+"/public/entry/"
  end

  def test_url_for_image_column_without_model_versions
    e = Entry.new(:image => upload("skanthak.png"))
    
    assert_nothing_raised { url_for_image_column e, "image", "50x50" }
  end
end
