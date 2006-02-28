require 'anansi/test/unit/base'	

class ShowParserTest < Test::Unit::TestCase
  def setup
    @parser = ShowParser.new("")
  end
  
  def teardown
  end
  
  def test_parse_as_date
    assert_date(2, 2, 2006, @parser.parse_as_date("2/2/06"))
    assert_date(2, 2, 2006, @parser.parse_as_date("2.2.06"))
    assert_date(2, 2, 2006, @parser.parse_as_date("02-02-06"))
    assert_date(2, 2, 2006, @parser.parse_as_date("02-02"))
    assert_date(2, 2, 2006, @parser.parse_as_date("02-02-2006 7pm"))
    assert_date(5, 10, 2006, @parser.parse_as_date("May 10"))
    assert_date(5, 10, 2006, @parser.parse_as_date("May 10, 06"))
    assert_date(5, 10, 2006, @parser.parse_as_date("May 10 2006"))
    
    assert_nil(@parser.parse_as_date("not a date", false))
    assert_raise(RuntimeError) { @parser.parse_as_date("not a date") }
  end
  
  def test_prepare_band_name
    assert_equal(["endgame", nil], @parser.prepare_band_name("& endgame"))
    assert_equal(["endgame", nil], @parser.prepare_band_name("endgame"))
    assert_equal(["crisis bureau", nil], @parser.prepare_band_name("crisis bureau  "))
    assert_equal(["crisis bureau", "(ex-endgame)"], 
                 @parser.prepare_band_name("crisis bureau (ex-endgame)"))
    assert_equal(["crisis bureau", "[ex-endgame]"], 
                 @parser.prepare_band_name("crisis bureau [ex-endgame]"))
    assert_equal(["crisis bureau", "- one night only!"], 
                 @parser.prepare_band_name("crisis bureau - one night only!"))
  end
  
  def test_process_first_band
    assert_equal(["endgame", nil], @parser.process_first_band("endgame"))
    assert_equal(["crisis bureau (ex-endgame)", nil], @parser.process_first_band("crisis bureau (ex-endgame)"))
    
    assert_equal(nil, @parser.process_first_band("A show featuring"))
    assert_equal(nil, @parser.process_first_band("Gasry productions presents:"))
    assert_equal(nil, @parser.process_first_band("Gasry productions presents"))
    assert_equal(nil, @parser.process_first_band("Mike and Gary present"))
    assert_equal(nil, @parser.process_first_band("all the way from england a very special guest"))
    
    assert_equal(["endgame", "a show featuring"], @parser.process_first_band("a show featuring endgame"))
    assert_equal(["crisis bureau", "a record label presents:"], @parser.process_first_band("a record label presents: crisis bureau"))
    assert_equal(["crisis bureau", "webster presents a show featuring"], 
                 @parser.process_first_band("webster presents a show featuring crisis bureau"))
    assert_equal(["crisis bureau", "webster featuring a show presents"], 
                 @parser.process_first_band("webster featuring a show presents crisis bureau"))
  end
end