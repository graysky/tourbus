# Sends us user-submitted feedback
class FeedbackMailer < BaseMailer

  # For when a user submits feedback about the site
  def notify_feedback(feedback, user, email, sent_at = Time.now)

    @subject    = "[tourbus] New Feedback"
    @recipients = Emails.feedback
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    content_type "text/html"
    
    @body["sent"] = "#{sent_at}"
    @body["user"] = user
    @body["email"] = email
    @body["feedback"] = feedback
  end

end
