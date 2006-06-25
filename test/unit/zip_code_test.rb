require File.dirname(__FILE__) + '/../test_helper'

class ZipCodeTest < Test::Unit::TestCase
  fixtures :zip_codes

  def test_simple
    z = zip_codes(:ashland)
    assert_equal "Ashland", z.city
  end
end
