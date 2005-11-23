class FanMailer < ActionMailer::Base

  def notify_signup(fan, confirm_url, sent_at = Time.now)
    @subject    = 'TourBus Account Confirmation'
    @recipients = fan.contact_email
    @from       = 'noreply@mytourb.us'
    @sent_on    = sent_at
    @headers    = {}
    content_type "text/html"
    
    @body["fan"] = fan
    @body["confirm_url"] = confirm_url
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
