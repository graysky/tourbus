# Notifications sent out when a new comment is posted
class CommentMailer < ActionMailer::Base

  # For when a new comment has been posted
  # comment => The new comment
  # recipients => string or array of recipients
  def notify_comment(comment, recipients, sent_at = Time.now)
    @subject    = '[TourBus] New Comment Posted'
    @recipients = recipients
    @from       = 'noreply@mytourb.us'
    @sent_on    = sent_at
    @headers    = {}
    content_type "text/html"
    
    @body["comment"] = comment
  end
  
end
