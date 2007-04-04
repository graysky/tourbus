# Sends out email about favorites
class FavoritesMailer < BaseMailer
  
  # NOTE: This sends multipart emails for HTML and plaintext
  def favorites_update(fan, new_shows, updated_shows, sent_at = Time.now)
    
    pop_bands = calc_popular_bands(new_shows)
    title = pop_bands.map { |b| b.name }.join(", ")
    
    @subject    = "[tourb.us] Your Upcoming Shows with #{title}"
    @body       = {}
    @recipients = fan.contact_email
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    
    @body['fan'] = fan
    @body['new_shows'] = new_shows
    @body['updated_shows'] = updated_shows
    
    @body['show_prefix_url'] = show_prefix_url
    @body['band_prefix_url'] = band_prefix_url
    @body['email_signoff'] = email_signoff
    @body['email_signoff_plain'] = email_signoff_plain
  end
  
  def no_location(fan, sent_at = Time.now)
    @subject    = '[tourb.us] Problem sending upcoming show emails'
    @body       = {}
    @recipients = fan.contact_email
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    @content_type = "text/html"
    
    @body['fan'] = fan
    @body['email_signoff'] = email_signoff
  end
  
  # Reminder for those without any favorite bands
  def add_faves_reminder(fan, sent_at = Time.now)
    @subject    = '[tourb.us] Track Your Favorite Bands'
    @body       = {}
    @recipients = fan.contact_email
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    
    @body['fan'] = fan
    @body['the_url'] = "http://tourb.us/fans/import_favorites"
    @body['email_signoff'] = email_signoff
    @body['email_signoff_plain'] = email_signoff_plain
  end
  
  # Return the 3 most popular bands from list of shows
  def calc_popular_bands(shows)
    bands = []
    # Get all the bands
    shows.each { |s| bands << s.bands }
    bands.flatten!
    # Remove dupes
    bands.uniq!
    # Sort them
    pop_bands = bands.sort { |a,b| b.popularity <=> a.popularity }
    
    # Return up to 3 bands
    if pop_bands.size > 3
      return pop_bands[0..2]
    else
      return pop_bands
    end
    
  end
  
  # Remind all fans to add favorites
  def self.do_add_favorites_reminder
    # Get all those who haven't been reminded
    fans = Fan.find_all_by_last_faves_reminder(nil)

    FavoritesMailer.do_add_favorites_reminder_for_fans(fans)
  end
  
  # Remind fans to add faves iff:
  # - they have no favorite bands
  # - they have not been nagged before
  # - they signed up >48 hours before
  # 
  # Note: Allows testing with subset of fans
  def self.do_add_favorites_reminder_for_fans(fans)
    
    for fan in fans
      if !fan.bands.empty?
        # Don't need to bother them. Update their record
        # to avoid them next time
        fan.last_faves_reminder = Time.now
        fan.save
        next
      end
      
      next if !fan.allow_contact?
      
      # Never bother people twice
      next if !fan.last_faves_reminder.nil?
      
      # Wait until 48 hours after signing up
      next if fan.created_on > Time.now - 48.hours
      
      OFFLINE_LOGGER.info("Reminding fan to add bands: #{fan.id}, #{fan.name}")

      FavoritesMailer.deliver_add_faves_reminder(fan)
      
      # Update them to avoid future nagging
      fan.last_faves_reminder = Time.now
      fan.save
    end
  end
  
  # Main entry point from the runner script.
  # Calculates what emails need to be sent to fans that have specified
  # favorites bands to receive updates about
  # NOTE: Won't scale to huge numbers of users, but my guess is limiting
  # factor might actually be the time it takes to send mail.
  def self.do_favorites_updates
    fans = Fan.find_all_by_wants_favorites_emails(true)
    num_fans = 0
    all_start = Time.now.to_i
    for fan in fans
      start = Time.now
      OFFLINE_LOGGER.info("Start fan: #{fan.id}, #{start.to_i}")
      
      # Are they are any favorites?
      next if fan.bands.empty?
      
      # Make sure the fan has set a location. If not, bug them once.
      if fan.zipcode == "" and fan.city == ""
        if fan.last_favorites_email.nil? 
          FavoritesMailer.deliver_no_location(fan)
          fan.last_favorites_email = Time.now
          fan.no_update
          fan.save
        end
        
        next
      end
      
      # Time of the last update
      updated_since = fan.last_favorites_email.nil? ? Time.local(2000) : fan.last_favorites_email
      
      faves = FavoritesCalculator.new(fan, updated_since)
      
      # NOTE: Right now we are not sending updated shows. Should we be?
      new_shows = faves.new_shows
      OFFLINE_LOGGER.info("  Found #{new_shows.size} new ones")
      next if new_shows.empty?
      
      # The user is watching each show
      new_shows.each do |show|
        # Hack... read only records are returned from the calculator. 
        show = Show.find(show.id)
        fan.watch_show(show)
        show.save
      end
      
      FavoritesMailer.deliver_favorites_update(fan, new_shows, nil)
      fan.last_favorites_email = Time.now
      fan.save
      
      num_fans += 1
    end
    
    finish = Time.now
    
    OFFLINE_LOGGER.info("Faves timing: #{finish.to_i - all_start.to_i}")
    
    SystemEvent.info("Sent #{num_fans} favorites emails", SystemEvent::FAVORITES)
  end
end
