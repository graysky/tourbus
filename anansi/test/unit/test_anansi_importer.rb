require 'anansi/test/unit/base'  

class AnansiImporterTest < Test::Unit::TestCase
  def setup
    @importer = AnansiImporter.new()
  end
  
  def teardown
  end
  
  # Test that capitalization if fixed correctly
  def test_fix_capitalization
    # It should not change this case
    importer = AnansiImporter.new
    assert_equal("my band", importer.fix_capitalization("my band"))
    assert_equal(nil, importer.fix_capitalization(nil))
    assert_equal("f.o.o.", importer.fix_capitalization("f.o.o."))
    assert_equal("MY Band", importer.fix_capitalization("MY Band"))

    # It should fix this case    
    assert_equal("My Band", importer.fix_capitalization("MY BAND"))
  end
  
end