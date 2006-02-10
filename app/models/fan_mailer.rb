class FanMailer < BaseMailer

  def notify_signup(fan, confirm_url, sent_at = Time.now)
    @subject    = '[tourbus] Account Confirmation'
    @recipients = fan.contact_email
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    content_type "text/html"
    
    @body["fan"] = fan
    @body["confirm_url"] = confirm_url
  end
  
  def forgot_password(fan, url, sent_at = Time.now)
    @subject    = '[tourbus] Reset Your Password'
    @recipients = fan.contact_email
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    content_type "text/html"
    
    @body["fan"] = fan
    @body["url"] = url
  end

  def confirmation(sent_at = Time.now)
    @subject    = 'FanMailer#confirmation'
    @body       = {}
    @recipients = ''
    @from       = ''
    @sent_on    = sent_at
    @headers    = {}
  end
end
