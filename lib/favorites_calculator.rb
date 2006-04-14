# Calculates upcoming shows by favorite bands
class FavoritesCalculator

  # Create new calculator, with a time specifying how far back to check
  # for new shows by favorites
  def initialize(fan, updated_since)
    @fan = fan
    @updated_since = updated_since
    
    # Assume that if we got here the fan has a location set
    if fan.zipcode != ""
      zipcode = ZipCode.find_by_zip(fan.zipcode)
    else
      # TODO Deal with multi-zip cities
      zipcode = ZipCode.find_by_city_and_state(fan.city, fan.state)
    end
    
    @lat = zipcode.latitude
    @long = zipcode.longitude
  end
  
  # New shows played by the favorites
  def new_shows
    upcoming_shows.find_all { |show| show.created_on >= @updated_since }
  end
  
  # Updated shows played by the favorites
  def updated_shows
    upcoming_shows.find_all { |show| show.created_on < @updated_since }
  end
  
  private
  
  # All upcoming shows within range for all favorites bands
  # Includes shows that have been created since the last email
  # and shows that have been updated since.
  def upcoming_shows
    if @upcoming_shows.nil?
      @upcoming_shows = []
      
      @fan.bands.each do |band|
        shows = band.shows.find(:all, 
                                :conditions => ["date >= ? and last_updated > ?", 
                                Time.now, @updated_since],
                                :readonly => false)
                                
        if shows.size > 0
          # Reselect so the records aren't R/O                        
          sql = 'id in (' + shows.map { |show| show.id }.join(',') + ')'
          shows = Show.find(:all, :conditions => sql)
        end
        
        # Only find shows in range
        shows = shows.find_all do |show|
          Address::is_within_range(show.venue.latitude.to_f, show.venue.longitude.to_f, @lat.to_f, @long.to_f, @fan.default_radius)
        end
        
        # Remove any dupes
        @upcoming_shows = @upcoming_shows | shows
      end
      
      # Sort the combined list by date
      @upcoming_shows.sort! { |x,y| x.date <=> y.date }
    end
    
    @upcoming_shows
  end
end