class FavoritesMailer < ActionMailer::Base
  
  def favorites_update(fan, new_shows, updated_shows, sent_at = Time.now)
    @subject    = '[tourbus] Your List of Upcoming Shows'
    @body       = {}
    @recipients = fan.contact_email
    @from       = 'noreply@mytourb.us'
    @sent_on    = sent_at
    @headers    = {}
    @content_type = "text/html"
    
    @body['fan'] = fan
    @body['new_shows'] = new_shows
    @body['updated_shows'] = updated_shows
    
    # FIXME How do I get the URL here without being in a controller?
    # Maybe the favorites logic should be in a controller and can pass the url in here
    @body['url_prefix'] = 'http://mytourb.us/show/'
  end
  
  def no_location(fan, sent_at = Time.now)
    @subject    = '[tourbus] Problem sending upcoming show emails'
    @body       = {}
    @recipients = fan.contact_email
    @from       = 'noreply@mytourb.us'
    @sent_on    = sent_at
    @headers    = {}
    @content_type = "text/html"
    
    @body['fan'] = fan
  end
  
  # Main entry point from the runner script.
  # Calculates what emails need to be sent to fans that have specified
  # favorites bands to receive updates about
  # NOTE: Won't scale to huge numbers of users, but my guess is limiting
  # factor might actually be the time it takes to send mail.
  def self.do_favorites_updates
    fans = Fan.find(:all)
    for fan in fans
      # Are they are any favorites?
      next if fan.bands.empty?
      
      # Make sure the fan has set a location. If not, bug them once.
      if fan.zipcode == "" and fan.city == ""
        if fan.last_favorites_email.nil? 
          FavoritesMailer.deliver_no_location(fan)
          fan.last_favorites_email = Time.now
          fan.save_without_indexing
        end
        
        next
      end
      
      faves = FavoritesCalculator.new(fan)
      
      # NOTE: Right now we are not sending updated shows. Should we be?
      new_shows = faves.new_shows
      next if new_shows.empty?
      
      FavoritesMailer.deliver_favorites_update(fan, new_shows, nil)
      fan.last_favorites_email = Time.now
      fan.save_without_indexing
    end
  end
  
  class FavoritesCalculator
    def initialize(fan)
      @fan = fan
      
      # Assume that if we got here the fan has a location set
      if fan.zipcode != ""
        zipcode = ZipCode.find_by_zip(fan.zipcode)
      else
        # TODO Deal with multi-zip cities
        zipcode = ZipCode.find_by_city_and_state(fan.city, fan.state)
      end
      
      @lat = zipcode.latitude
      @long = zipcode.longitude
      
      @updated_since = @fan.last_favorites_email.nil? ? Time.local(2000) : @fan.last_favorites_email
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
                                  Time.now, @updated_since])
          
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
end
