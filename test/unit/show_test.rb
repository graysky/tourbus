require File.dirname(__FILE__) + '/../test_helper'

class ShowTest < Test::Unit::TestCase
  #fixtures :shows

  def setup
    #@show = Show.find(1)
  end

  def test_band
    #assert_equal 1, @show.band.id
  end
  
  def test_formatted_dates
    show = Show.new
    show.date = Time.local(*ParseDate.parsedate("October 10, 2005 1:45PM"))
    assert_equal "October 10, 2005", show.formatted_date
    assert_equal "PM", show.time_ampm
    assert_equal 45, show.time_minute
    assert_equal 1, show.time_hour
    
    show.date = Time.local(*ParseDate.parsedate("October 10, 2005 12:00AM"))
    assert_equal "AM", show.time_ampm
    assert_equal 0, show.time_minute
    assert_equal 12, show.time_hour
  end
end
