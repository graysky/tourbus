# Sends us user-submitted feedback
class FeedbackMailer < BaseMailer

  # For when a user submits feedback about the site
  def notify_feedback(type, feedback, user, email, sent_at = Time.now)

    @subject    = "[tourb.us] New Feedback"
    @recipients = Emails.feedback
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    content_type "text/html"
    
    @body["sent"] = "#{sent_at.asctime}"
    @body["user"] = user
    @body["email"] = email
    @body["feedback"] = feedback
    @body["type"] = type    
  end

  # For when a user reports a problem with the site
  def problem_report(type, id, reason, notes, fan, sent_at = Time.now)
    @subject    = "[tourb.us] Problem Report"
    @recipients = Emails.feedback
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    content_type "text/html"
    
    @body["sent"] = "#{sent_at}"
    @body["fan"] = fan.nil? ? "Anonymous" : fan.name
    @body["fan_email"] = fan.nil? ? "no email" : fan.contact_email
    @body["type"] = type
    @body["id"] = id
    @body["notes"] = notes
    @body["reason"] = reason
  end
  
  # Compile stast on the last day of activity
  def nightly_stats()
    @subject    = "[tourb.us] Nightly Stats"
    @recipients = Emails.gm
    @from       = Emails.from
    @sent_on    = Time.now
    @headers    = {}
    content_type "text/html"
    
    # Change to do faster direct SQL count(*) calls
    recent_fans = Fan.find(:all, :conditions => ["created_on > ?", Time.now - 1.days])
    recent_logins = Fan.find(:all, :conditions => ["last_login > ?", Time.now - 1.days])

    # Totals
    fans = Fan.count
    bands = Band.count
    venues = Venue.count
    shows = Show.count
    upcoming_shows = Show.find(:all, :conditions => ["date > ?", Time.now - 1.days])
    
    # Added favorites
    lastfm_adds = FavoriteBandEvent.find(:all, :conditions => ["created_at > ? and source=?", Time.now - 1.days, FavoriteBandEvent::SOURCE_LASTFM_POLL])
    import_adds = FavoriteBandEvent.find(:all, :conditions => ["created_at > ? and source=?", Time.now - 1.days, FavoriteBandEvent::SOURCE_IMPORT])
    fan_adds = FavoriteBandEvent.find(:all, :conditions => ["created_at > ? and source=?", Time.now - 1.days, FavoriteBandEvent::SOURCE_FAN])
    
    # Events
    sharing_events = SystemEvent.find(:all, :conditions => ["created_at > ? and area=?", Time.now - 1.days, SystemEvent::SHARING])
    reminder_events = SystemEvent.find(:all, :conditions => ["created_at > ? and area=?", Time.now - 1.days, SystemEvent::REMINDERS])
    
    @body["fans"] = fans
    @body["recent_fans"] = recent_fans
    @body["recent_logins"] = recent_logins
    @body["bands"] = bands
    @body["venues"] = venues
    @body["shows"] = shows
    @body["upcoming_shows"] = upcoming_shows
    @body["lastfm_adds"] = lastfm_adds
    @body["import_adds"] = import_adds
    @body["fan_adds"] = fan_adds
    @body["sharing_events"] = sharing_events
    @body["reminder_events"] = reminder_events
    
  end
end
