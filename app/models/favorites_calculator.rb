# Calculates upcoming shows by favorite bands
class FavoritesCalculator

  @@BAND_SHOWS = {}
  
  # Create new calculator, with a time specifying how far back to check
  # for new shows by favorites
  def initialize(fan, updated_since)
    @fan = fan
    @updated_since = updated_since
  end
  
  # New shows played by the favorites
  def new_shows
    upcoming_shows.find_all { |show| show.created_on >= @updated_since }
  end
  
  # Updated shows played by the favorites
  def updated_shows
    upcoming_shows.find_all { |show| show.created_on < @updated_since }
  end
  
  protected
  
  # All upcoming shows within range for all favorites bands
  # Includes shows that have been created since the last email
  def upcoming_shows
    if @upcoming_shows.nil?
      OFFLINE_LOGGER.info("    Get shows: #{Time.now}")
      start = Time.now.to_i
      @upcoming_shows = []

      # Defense against no location set
      return [] if @fan.latitude.nil? or @fan.latitude.empty?
      
      now = Time.now
      bids = @fan.bands.map { |b| b.id }.select { |id| @@BAND_SHOWS[id].nil? }
      bands = Band.find(:all, :conditions => ["bands.id in (?)", bids], :include => :upcoming_shows)
      cached_ids = @fan.bands.map { |b| b.id }.select { |id| @@BAND_SHOWS[id] }
      bands += cached_ids
      bands.each do |band|
        shows = shows_for_band(band).collect do |show| 
          show.date > now && show.last_updated > @updated_since ? show : nil
        end
        shows = Show.within_range(shows, @fan.latitude.to_f, @fan.longitude.to_f, @fan.default_radius)

	OFFLINE_LOGGER.info("          found #{shows.size} show for #{band.name}")
           
        # Remove any dupes and shows the user is already going to
        @upcoming_shows += (shows - @fan.upcoming_shows)
      end
      
      # Sort the combined list by date
      @upcoming_shows.uniq!
      @upcoming_shows.sort! { |x,y| x.date <=> y.date }
      OFFLINE_LOGGER.info("    Done: #{Time.now.to_i - start}, #{@upcoming_shows.size}")
    end
    
    @upcoming_shows
  end
  
  def shows_for_band(b)
   id = b.is_a?(Integer) ? b : b.id
    shows = @@BAND_SHOWS[id]
    if shows.nil?
      shows = @@BAND_SHOWS[id] = b.upcoming_shows
    end
    
    shows
  end
end