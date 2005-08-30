class BandMailer < ActionMailer::Base

  def notify_signup(band, url, sent_at = Time.now)
    @subject    = 'TourBus Account Confirmation'
    @recipients = band.contact_email
    @from       = 'noreply@mytourb.us'
    @sent_on    = sent_at
    @headers    = {}
    content_type "text/html"
    
    @body["band"] = band
    @body["url"] = url
  end

  def notify_confirmed(sent_at = Time.now)
    @subject    = 'BandMailer#confirmed'
    @body       = {}
    @recipients = ''
    @from       = ''
    @sent_on    = sent_at
    @headers    = {}
  end
end