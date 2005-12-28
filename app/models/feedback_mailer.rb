# Sends us user-submitted feedback
class FeedbackMailer < ActionMailer::Base

  # For when a user submits feedback about the site
  def notify_feedback(feedback, user, email, sent_at = Time.now)

    # Send to all of us - TODO Should include TB email address
    recipients = ['mike_champion@yahoo.com', 'garypelliott@yahoo.com']
  
    @subject    = "[TourBus] New Feedback"
    @recipients = recipients
    @from       = 'noreply@mytourb.us'
    @sent_on    = sent_at
    @headers    = {}
    content_type "text/html"
    
    @body["sent"] = "#{sent_at}"
    @body["user"] = user
    @body["email"] = email
    @body["feedback"] = feedback
    
  end

end
