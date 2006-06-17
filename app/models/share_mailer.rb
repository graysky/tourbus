# Mailer to let fans spread the word about a show and inviting to tourb.us
class ShareMailer < BaseMailer

  # Send an email to a friend about a show
  def share_show(to_addrs, from_name, show, msg, sent_at = Time.now)
    @subject    = "[tourb.us] Invitation: #{show.formatted_title}"
    @body       = {}
    @recipients = to_addrs
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    
    @body['msg'] = msg
    @body['from_name'] = from_name
    
    @body['show'] = show
    @body['band_prefix_url'] = band_prefix_url
    @body['show_prefix_url'] = show_prefix_url
    @body['email_signoff'] = email_signoff
    @body['email_signoff_plain'] = email_signoff_plain
  end
  
  # Send an email to a friend about trying tourb.us
  def invite_friend(to_addrs, from_name, fan, msg, sent_at = Time.now)
    @subject    = "Invitation to tourb.us from #{from_name}"
    @body       = {}
    @recipients = to_addrs
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    
    @body['fan'] = fan
    @body['msg'] = msg
    @body['from_name'] = from_name
    
    @body['fan_prefix_url'] = fan_prefix_url
    @body['email_signoff'] = email_signoff
    @body['email_signoff_plain'] = email_signoff_plain
  end
end
