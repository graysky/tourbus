require 'anansi/test/unit/base'	

class ShowParserTest < Test::Unit::TestCase
  def setup
    @parser = ShowParser.new("")
  end
  
  def teardown
  end
  
  def test_parse_as_date
    assert_date(2, 2, 2006, @parser.parse_as_date("2/2/06"))
  end
end