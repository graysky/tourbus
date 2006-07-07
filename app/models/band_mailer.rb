# Mailer for signing up bands
class BandMailer < BaseMailer

  def notify_signup(band, confirm_url, public_url, sent_at = Time.now)
    @subject    = '[tourb.us] Account Confirmation'
    @recipients = band.contact_email
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    content_type "text/html"
    
    @body["band"] = band
    @body["confirm_url"] = confirm_url
    @body["public_url"] = public_url
    @body['email_signoff'] = email_signoff
  end

  def forgot_password(band, url, sent_at = Time.now)
    @subject    = '[tourb.us] Reset Your Password'
    @recipients = band.contact_email
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    content_type "text/html"
    
    @body["band"] = band
    @body["url"] = url
    @body['email_signoff'] = email_signoff
  end

  def notify_confirmed(sent_at = Time.now)
    @subject    = 'BandMailer#confirmed'
    @body       = {}
    @recipients = ''
    @from       = ''
    @sent_on    = sent_at
    @headers    = {}
  end
  
  # New band signup - tell Gary and Mike!
  def gm_of_new_band(band)
    @subject    = '[tourb.us] New Band Signup!'
    @recipients = Emails.gm
    @from       = Emails.from
    @sent_on    = Time.now
    @headers    = {}
    content_type "text/html"
    
    @body["band"] = band
  end
end
