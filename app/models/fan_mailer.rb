class FanMailer < BaseMailer

  def notify_signup(fan, confirm_url, sent_at = Time.now)
    @subject    = '[tourb.us] Account Confirmation'
    @recipients = fan.contact_email
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    
    @body["fan"] = fan
    @body["confirm_url"] = confirm_url

    @body['email_signoff'] = email_signoff
    @body['email_signoff_plain'] = email_signoff_plain
  end
  
  def forgot_password(fan, url, sent_at = Time.now)
    @subject    = '[tourb.us] Password Reset Request'
    @recipients = fan.contact_email
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    
    @body["fan"] = fan
    @body["url"] = url
    @body['email_signoff'] = email_signoff
    @body['email_signoff_plain'] = email_signoff_plain
  end
  
  def wishlist_to_favorites(fan, bands, sent_at = Time.now)
    @subject    = '[tourb.us] We Found Bands On Your Wishlist'
    @recipients = fan.contact_email
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    
    @body["fan"] = fan
    @body["bands"] = bands
    @body['band_prefix_url'] = band_prefix_url
    @body['show_prefix_url'] = show_prefix_url
    @body['email_signoff'] = email_signoff
    @body['email_signoff_plain'] = email_signoff_plain
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
