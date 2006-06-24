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
  def upcoming_shows
    if @upcoming_shows.nil?
      @upcoming_shows = []
      
      now = Time.now
      @fan.bands.each do |band|
        
        shows = band.shows.collect do |show| 
          show.date > now && show.last_updated > @updated_since ? show : nil
        end
        shows = Show.within_range(shows, @lat.to_f, @long.to_f, @fan.default_radius)
           
        # Remove any dupes and shows the user is already going to
        @upcoming_shows += (shows - @fan.upcoming_shows)
      end
      
      # Sort the combined list by date
      @upcoming_shows.uniq!
      @upcoming_shows.sort! { |x,y| x.date <=> y.date }
    end
    
    @upcoming_shows
  end
end