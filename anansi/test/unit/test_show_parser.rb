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
  
  def test_parse_as_time
    assert_equal("9am", @parser.parse_as_time("9am"))
    assert_equal("9 am", @parser.parse_as_time("9 am"))
    assert_equal("10 PM", @parser.parse_as_time("10 PM"))
    assert_equal("12:30pm", @parser.parse_as_time("12:30pm"))
    assert_equal("12:30", @parser.parse_as_time("12:30"))
    
    assert_nil(@parser.parse_as_time("7"))
    assert_nil(@parser.parse_as_time("12 o'clock"))
    assert_nil(@parser.parse_as_time("backswash"))
  end
  
  def test_parse_as_age_limit
    assert_equal("18+", @parser.parse_as_age_limit("18+"))
    assert_equal("21+", @parser.parse_as_age_limit("this how is 21+ only"))
    assert_equal("all ages", @parser.parse_as_age_limit("all ages"))
    assert_equal("all ages", @parser.parse_as_age_limit("a/a"))
    
    assert_nil(@parser.parse_as_age_limit("anyone is welcome"))
  end
  
  def test_parse_as_cost
    assert_equal("$7", @parser.parse_as_cost("$7"))
    assert_equal("$7.50", @parser.parse_as_cost("$7.50"))
    assert_equal("$7", @parser.parse_as_cost("cost is $7"))
    
    assert_nil(@parser.parse_as_cost("eleven"))
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
    assert_equal(["Josh Rouse", "PASTE presents an evening with"], 
                 @parser.process_first_band("PASTE presents an evening with Josh Rouse"))
  end
  
  def test_probable_band
    assert_nil(@parser.probable_band("TBA", 0, nil))
    assert_nil(@parser.probable_band("t.b.a", 1, nil))
    assert_equal({ :name => "crisis bureau" }, @parser.probable_band("crisis bureau", 1, nil))
    assert_equal({ :name => "christmas presents" }, @parser.probable_band("christmas presents", 1,  nil)) 
    assert_nil(@parser.probable_band("christmas presents", 0, nil))
  end
end