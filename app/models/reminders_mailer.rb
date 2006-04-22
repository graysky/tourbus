# Mailer to send reminders about shows
class RemindersMailer < BaseMailer
  
  # Sends a test email for SMS-like viewing
  def sms_test(mobile_email, sent_at = Time.now)
    @subject    = "Success!"
    @body       = {}
    @recipients = mobile_email
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    @content_type = "text/plain"
  end
  
  # Sends an email for SMS-like viewing
  def sms_reminder(fan, show, sent_at = Time.now)
    @subject    = "Show Reminder"
    @body       = {}
    @recipients = fan.mobile_email
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    @content_type = "text/plain"
    
    @body['fan'] = fan
    @body['show'] = show
    
    @body['url_prefix'] = show_prefix_url
  end
  
  # Sends an email reminder about a show
  def email_reminder(fan, show, sent_at = Time.now)
    @subject    = "[tourb.us] Reminder: #{show.formatted_title}"
    @body       = {}
    @recipients = fan.contact_email
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    @content_type = "text/html"
    
    @body['fan'] = fan
    @body['show'] = show
    
    @body['band_prefix_url'] = band_prefix_url
    @body['show_prefix_url'] = show_prefix_url
    @body['email_signoff'] = email_signoff
  end
  
  # Sends an email reminder about a watched show
  def email_reminder_for_watch(fan, show, sent_at = Time.now)
    @subject    = "[tourb.us] Reminder: #{show.formatted_title}"
    @body       = {}
    @recipients = fan.contact_email
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    @content_type = "text/html"
    
    @body['fan'] = fan
    @body['show'] = show
    
    @body['url_prefix'] = show_prefix_url
    @body['email_signoff'] = email_signoff
  end
  
  # Main entry point from the runner script.
  # Calculates what emails need to be sent to fans that have specified
  # show reminders that need to be sent
  # NOTE: Possible that a user changing setting will miss a reminder
  def self.do_show_reminders
    
    logger.info "Sending show reminders at #{Time.now.asctime}"
    p "Sending show reminders at #{Time.now.asctime}"
    
    fans = Fan.find(:all)
    for fan in fans
      # Skip this fan if they don't have reminders enabled
      next if not (fan.wants_email_reminder? or fan.wants_mobile_reminder?)
      
      reminders = RemindersCalculator.new(fan)
      
      upcoming_shows = reminders.upcoming_shows
      watching_shows = fan.shows.find(:all, :conditions => ["date > ? and watching = 1", Time.now])
      
      # Skip this fan if they don't have any upcoming shows
      next if (upcoming_shows.nil? or upcoming_shows.empty?) and watching_shows.empty?
      
      now = Time.now
      
      # Only update the fan after we've checked ALL shows
      # or we won't send reminders correctly
      save_fan = false
      
      # For each upcoming show, calculate if a reminder is needed
      for show in upcoming_shows
        
        needs_reminder = false
        
        # Check 1st reminder        
        if fan.show_reminder_first > 0
          
          if now + (60 * fan.show_reminder_first) >= show.date
            
            # A reminder needs to be sent. Was it already sent?
            if fan.last_show_reminder.nil? or
             (fan.last_show_reminder + (60 * fan.show_reminder_first) < show.date)
              
              # Nope, hasn't been sent yet
              needs_reminder = true
            end
          end
        end
        
        # Check 2nd reminder
        if fan.show_reminder_second > 0 and !needs_reminder
          
          if now + (60 * fan.show_reminder_second) >= show.date
            
            # A reminder needs to be sent. Was it already sent?
            if fan.last_show_reminder.nil? or
              (fan.last_show_reminder + (60 * fan.show_reminder_second) < show.date)
              
              # Nope, hasn't been sent yet
              needs_reminder = true
            end
          end
        end
        
        # Needs a reminder sent
        if needs_reminder
          # Find out what kind of reminder
          if fan.wants_email_reminder?
            RemindersMailer.deliver_email_reminder(fan, show)
          end
            
          if fan.wants_mobile_reminder?
            RemindersMailer.deliver_sms_reminder(fan, show)
          end
          
          # The fan has had reminders sent, update him
          save_fan = true
        end      
          
      end # shows loop
      
      # TODO Factor all this logic out. Use cool ruby features to do so.
      # Write unit tests to verify.
      #
      # Now check shows the fan is watching
      if watching_shows.size > 0
        for show in watching_shows
        
          if fan.show_watching_reminder > 0
           
            if now + (60 * fan.show_watching_reminder) >= show.date
              
              # A reminder needs to be sent. Was it already sent?
              if fan.last_show_reminder.nil? or
                (fan.last_show_reminder + (60 * fan.show_watching_reminder) < show.date)
                
                RemindersMailer.deliver_email_reminder_for_watch(fan, show)
                save_fan = true
              end
            end
          end
          
        end
      end
      
      if save_fan
        logger.info "Updating fan at #{now}"
        fan.last_show_reminder = now
        fan.save
      end
      
    end # fan loop 
  end
  
  # Calculate which shows need reminders
  class RemindersCalculator
    def initialize(fan)
      @fan = fan
    end
    
    # All upcoming shows that the fan is signed up to attend
    def upcoming_shows
      
      shows = []
      shows = @fan.shows.find(:all, :conditions => ["date > ? and attending = 1", Time.now])
    end 
  end
  
end