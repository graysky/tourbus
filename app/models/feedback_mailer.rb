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
  
  def nightly_stats(fans, recent_fans, recent_logins, 
      bands, venues, shows, upcoming_shows)
    @subject    = "[tourb.us] Nightly Stats"
    @recipients = Emails.gm
    @from       = Emails.from
    @sent_on    = Time.now
    @headers    = {}
    content_type "text/html"
    
    @body["fans"] = fans
    @body["recent_fans"] = recent_fans
    @body["recent_logins"] = recent_logins
    @body["bands"] = bands
    @body["venues"] = venues
    @body["shows"] = shows
    @body["upcoming_shows"] = upcoming_shows
  end
end
