require File.dirname(__FILE__) + '/../test_helper'

class FanTest < Test::Unit::TestCase
  fixtures :fans

  def setup
    @fan = fans(:gary)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Fan,  @fan
  end
  
  def test_simple
    assert_equal "gary", @fan.name
  end
  
  def test_favorite
    band = bands(:green_arrows)
    assert @fan.favorite?(band)
    
    band = Band.new(:name => 'crisis bureau')
    assert !@fan.favorite?(band)
  end
  
  def test_add_favorite
    band = bands(:green_arrows)
    num_fans = band.num_fans
    num_faves = @fan.bands.size
    
    @fan.add_favorite(band)
    
    assert_equal num_fans, band.num_fans
    assert_equal num_faves, @fan.bands.size
    
    @fan.reload
    band = Band.new_band('test')
    @fan.add_favorite(band)
    
    assert_equal 1, band.num_fans
    assert_equal num_faves + 1, @fan.bands.size
  end
  
  def test_remove_favorite
    num_faves = @fan.bands.size
    
    band = Band.new_band('test')
    @fan.remove_favorite(band)
    
    assert_equal 0, band.num_fans
    assert_equal num_faves, @fan.bands.size
    
    band = bands(:green_arrows)
    num_fans = band.num_fans
    
    @fan.remove_favorite(band)
    
    assert_equal num_fans - 1, band.num_fans
    assert_equal num_faves - 1, @fan.bands.size
  end
  
  def test_attend_show
    show = Show.new(:date => Time.now)
    num_shows = @fan.shows.size
    
    @fan.attend_show(show)
    assert @fan.attending?(show)
    assert_equal num_shows + 1, @fan.shows.size
    assert_equal 1, show.num_attendees
    assert_equal 0, show.num_watchers
    
    @fan.attend_show(show)
    assert_equal num_shows + 1, @fan.shows.size
    assert_equal 1, show.num_attendees
    
    @fan.watch_show(show)
    assert @fan.watching?(show)
    assert !@fan.attending?(show)
    assert_equal num_shows + 1, @fan.shows.size
    assert_equal 0, show.num_attendees
    assert_equal 1, show.num_watchers
    
    @fan.watch_show(show)
    assert @fan.watching?(show)
    assert_equal 1, show.num_watchers  
  end
  
  def stop_attending_show
    show = @fan.shows[0]
  end
  
end
