# Notifications sent out when a new comment is posted
class PhotoMailer < BaseMailer

  # For when a new photo has been posted
  # photo => The new photo
  # recipients => string or array of recipients
  def notify_photo(photo, recipients, sent_at = Time.now)
    @subject    = '[tourb.us] New Photo Posted'
    @recipients = recipients
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    content_type "text/html"
    
    @body["photo"] = photo
    @body['email_signoff'] = email_signoff
  end
end
