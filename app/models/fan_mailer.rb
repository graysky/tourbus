class FanMailer < BaseMailer

  def notify_signup(fan, confirm_url, sent_at = Time.now)
    @subject    = '[tourb.us] Account Confirmation'
    @recipients = fan.contact_email
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    content_type "text/html"
    
    @body["fan"] = fan
    @body["confirm_url"] = confirm_url
    @body['email_signoff'] = email_signoff
  end
  
  def forgot_password(fan, url, sent_at = Time.now)
    @subject    = '[tourb.us] Reset Your Password'
    @recipients = fan.contact_email
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    content_type "text/html"
    
    @body["fan"] = fan
    @body["url"] = url
    @body['email_signoff'] = email_signoff
  end
  
  def wishlist_to_favorites(fan, bands, sent_at = Time.now)
    @subject    = '[tourb.us] We Found Bands On Your Wishlist'
    @recipients = fan.contact_email
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    content_type "text/html"
    
    @body["fan"] = fan
    @body["bands"] = bands
    @body['email_signoff'] = email_signoff
  end
  
  # New fan signup - tell Gary and Mike!
  def gm_of_new_fan(fan)
    @subject    = '[tourb.us] New Fan Signup!'
    @recipients = Emails.gm
    @from       = Emails.from
    @sent_on    = Time.now
    @headers    = {}
    content_type "text/html"
    
    @body["fan"] = fan
  end
end
