# Mailer to let fans spread the word about a show and inviting to tourb.us
class ShareMailer < BaseMailer

  # Share this show with the addresses provided. Attempts
  # to check for bad addresses and returns status message
  # Returns error message or nil on success
  def self.do_share_show(to_addrs, from_name, show, msg)
  
    if to_addrs.nil? or to_addrs.empty?
      return "No email address provided"
    end
    
    errors = ""
    
    # Try to deliver each share message
    to_addrs.each do |to|
      if !BaseMailer.valid_email?(to)
        errors << "Invalid address: #{to}"
        next
      end
      
      # Check for spam
      if BaseMailer.spam?(to)
        errors << "Suspected spam: #{to}"
        next
      end
      
      if BaseMailer.spam?(msg)
        errors << "Suspected spam: #{msg}"
        next
      end
    
      begin
        # Try to send the message
        ShareMailer.deliver_share_show(to, from_name, show, msg)
      rescue Exception => e
        errors << "Error sending: #{e.to_s}"
      end
    end
    
    errors = nil if errors.empty? 
    return errors
  end
  
  # Invite friends to join tourb.us
  # Attempts to check for bad addresses and returns status message
  # Returns error message or nil on success
  def self.do_invite_friend(to_addrs, from_name, fan, msg)
    if to_addrs.nil? or to_addrs.empty?
      return "No email address provided"
    end
    
    errors = ""
    
    # Try to deliver each message
    to_addrs.each do |to|
      if !BaseMailer.valid_email?(to)
        errors << "Invalid address: #{to}"
        next
      end
    
      begin
        # Try to send the message
        ShareMailer.deliver_invite_friend(to, from_name, fan, msg)
      rescue Exception => e
        errors << "Error sending: #{e.to_s}"
      end
    end
    
    errors = nil if errors.empty? 
    return errors
  end

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
