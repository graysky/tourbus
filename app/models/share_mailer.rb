# Mailer to let fans spread the word about a show.
class ShareMailer < BaseMailer

  # Send an email to a friend about a show
  def share_show(to_addrs, from_name, show, msg, sent_at = Time.now)
    @subject    = "[tourb.us] Invitation: #{show.formatted_title}"
    @body       = {}
    @recipients = to_addrs
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    
    #puts "Sharing show: #{show.title}"
    
    @body['msg'] = msg
    @body['from_name'] = from_name
    
    @body['show'] = show
    @body['band_prefix_url'] = band_prefix_url
    @body['show_prefix_url'] = show_prefix_url
    @body['email_signoff'] = email_signoff
    @body['email_signoff_plain'] = email_signoff_plain
  end
end
