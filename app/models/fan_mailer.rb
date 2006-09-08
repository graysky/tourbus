class FanMailer < BaseMailer

  def notify_signup(fan, confirm_url, sent_at = Time.now)
    @subject    = '[tourb.us] Account Confirmation'
    @recipients = fan.contact_email
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    
    @body["fan"] = fan
    @body["confirm_url"] = confirm_url
    @body["import_url"] = fan_private_prefix_url + 'import_favorites'

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
  
  def friend_request(request, confirm_url, deny_url, sent_at = Time.now)
    @subject    = "[tourb.us] #{request.requester.name} wants to be your friend"
    @recipients = request.requestee.contact_email
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    content_type "text/html"
    
    @body["request"] = request
    @body['email_signoff'] = email_signoff
    @body['email_signoff_plain'] = email_signoff_plain
    @body['confirm_url'] = confirm_url
    @body['deny_url'] = deny_url
    @body['friend_requests_url'] = fan_private_prefix_url + 'friend_requests'
  end
  
  def friend_request_confirmed(fan, friend, sent_at = Time.now)
    @subject    = "[tourb.us] #{friend.name} has confirmed your friend request"
    @recipients = fan.contact_email
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    content_type "text/html"
    
    @body['email_signoff'] = email_signoff
    @body['email_signoff_plain'] = email_signoff_plain
    @body['friend'] = friend
    @body['fan'] = fan
  end
  
  def friend_request_denied(fan, friend, sent_at = Time.now)
    @subject    = "[tourb.us] #{friend.name} has denied your friend request"
    @recipients = fan.contact_email
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    content_type "text/html"
    
    @body['email_signoff'] = email_signoff
    @body['email_signoff_plain'] = email_signoff_plain
    @body['friend'] = friend
    @body['fan'] = fan
  end
  
  def contact_fan(from, to, message, from_url, reveal_email, sent_at = Time.now)
    @subject    = "[tourb.us] You have a new message from  #{from.name}"
    @recipients = to.contact_email
    
    if reveal_email
      @from     = from.contact_email
    else
      @from     = Emails.from
    end
    
    @sent_on    = sent_at
    @headers    = {}
    content_type "text/plain"
    
    @body["from"] = from
    @body["to"] = to
    @body["message"] = message
    @body["from_url"] = from_url
    @body["reveal_email"] = reveal_email
    @body['email_signoff_plain'] = email_signoff_plain
  end
  
  def presale(fan)
    @subject    = '[tourb.us] Ticket Presale: Bob Dylan/The Raconteurs'
    @recipients = fan.contact_email
    @from       = Emails.from
    @sent_on    = Time.now
    @headers    = {}
    content_type "text/html"
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
