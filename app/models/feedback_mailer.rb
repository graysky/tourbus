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
    @recipients = "mike.champion@gmail.com" # Emails.gm
    @from       = Emails.from
    @sent_on    = Time.now
    @headers    = {}
    content_type "text/html"
    
    # Change to do faster direct SQL count(*) calls
    recent_fans = Fan.find(:all, :conditions => ["created_on > ?", Time.now - 1.days])
    recent_logins = Fan.find(:all, :conditions => ["last_login > ?", Time.now - 1.days])

    fans = Fan.count
    bands = Band.count
    venues = Venue.count
    shows = Show.count
    
    upcoming_shows = Show.find(:all, :conditions => ["date > ?", Time.now - 1.days])
    lastfm_adds = FavoriteBandEvent.find(:all, :conditions => ["created_at > ? and event=?", Time.now - 1.days, FavoriteBandEvent::SOURCE_LASTFM_POLL])
    
    # e = FavoriteBandEvent.find(:first, :conditions => ["fan_id=? and band_id=?", self.id, band.id], :order => "created_at desc")
    # e && e.event == FavoriteBandEvent::EVENT_REMOVE
    
    @body["fans"] = fans
    @body["recent_fans"] = recent_fans
    @body["recent_logins"] = recent_logins
    @body["bands"] = bands
    @body["venues"] = venues
    @body["shows"] = shows
    @body["upcoming_shows"] = upcoming_shows
    @body["lastfm_adds"] = lastfm_adds
  end
end
