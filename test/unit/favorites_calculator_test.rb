require File.dirname(__FILE__) + '/../test_helper'

class FavoritesCalculatorTest < Test::Unit::TestCase

  def setup
    @fan = fans(:mike)
  end

  # Test that it doesn't die on fans with no location
  def test_fan_no_location
    nobody = Fan.new
    nobody.name = "Fan without location"
    
    faves = FavoritesCalculator.new(nobody, Time.now - 1.year)
    assert(!faves.nil?)
    assert(faves.new_shows.empty?)
  end
  
  def test_basic
    faves = FavoritesCalculator.new(@fan, Time.now - 1.year)
    assert(!faves.nil?)
  end
end
