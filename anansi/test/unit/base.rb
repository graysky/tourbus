require 'test/unit'
require 'config/environment'

class Test::Unit::TestCase

  def assert_date(month, day, year, date)
    assert_equal(month, date.month)
    assert_equal(day, date.day)
    assert_equal(year, date.year)
  end
  
end