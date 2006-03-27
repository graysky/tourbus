require_dependency 'favorites_calculator'

# Sends out email about favorites
class FavoritesMailer < BaseMailer
  
  def favorites_update(fan, new_shows, updated_shows, sent_at = Time.now)
    @subject    = '[tourbus] Your List of Upcoming Shows'
    @body       = {}
    @recipients = fan.contact_email
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    @content_type = "text/html"
    
    @body['fan'] = fan
    @body['new_shows'] = new_shows
    @body['updated_shows'] = updated_shows
    
    @body['url_prefix'] = show_prefix_url
  end
  
  def no_location(fan, sent_at = Time.now)
    @subject    = '[tourbus] Problem sending upcoming show emails'
    @body       = {}
    @recipients = fan.contact_email
    @from       = Emails.from
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
      next if new_shows.empty?
      
      # The user is watching each show
      new_shows.each do |show|
        fan.watch_show(show)
        show.save
      end
      
      FavoritesMailer.deliver_favorites_update(fan, new_shows, nil)
      fan.last_favorites_email = Time.now
      fan.save
    end
  end

end
