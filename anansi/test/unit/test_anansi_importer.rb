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
    assert_equal("my band", AnansiImporter.fix_capitalization("my band"))
    assert_equal(nil, AnansiImporter.fix_capitalization(nil))
    assert_equal("f.o.o.", AnansiImporter.fix_capitalization("f.o.o."))
    assert_equal("MY Band", AnansiImporter.fix_capitalization("MY Band"))

    # It should fix this case    
    assert_equal("My Band", AnansiImporter.fix_capitalization("MY BAND"))
  end
  
end