# Notifications sent out when a new comment is posted
class CommentMailer < BaseMailer

  # For when a new comment has been posted
  # comment => The new comment
  # recipients => string or array of recipients
  def notify_comment(comment, recipients, sent_at = Time.now)
    @subject    = '[tourbus] New Comment Posted'
    @recipients = recipients
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    content_type "text/html"
    
    @body["comment"] = comment
  end
  
end
