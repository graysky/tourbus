require_dependency 'emails'

# Base class for all our ActionMailers
class BaseMailer < ActionMailer::Base

  # Common spam words
  SPAM_WORDS = ["phentermine", "levitra", "cialis", "viagra", 'ringtones', 'mattress' ] unless const_defined?("SPAM_WORDS")

  # Override deliver! to check for spam
  def deliver!(mail = @mail)
    #puts "Mail came through BaseMailer with #{mail.body}"
    if BaseMailer.spam?(mail.body)
      logger.info "Mail is suspected to be spam"
      return nil
    end

   obj = nil
   begin
     obj = super
   rescue Net::SMTPSyntaxError => e
     puts "ERROR: #{e.to_s}"
   end

   return obj
  end

  # Check the given string, returning true if spam, false if not
  def self.spam?(suspect)
    SPAM_WORDS.each do |s|
      return true if suspect.include?(s)
    end
    
    return false
  end

  # Check to see if this email should not be sent
  def email_testing?(addr)
    return Emails.spam.eql(addr)
  end

  # Tries to make best guess about whether the email
  # address is valid
  def self.valid_email?(addr)
    puts "Email is #{addr}"

    return false if addr.nil? or addr.empty?

    # Make sure it has @ symbol
    if addr !~ /@/
      return false
    end
        
    return true
  end

  ## This is lame - better to share across with ActiveController helpers
  
  # Return the URL prefix *before* a band name
  def band_prefix_url
    return Emails.url + "/"
  end

  # Get the prefix url for shows
  def show_prefix_url
    return Emails.url + "/show/"
  end
  
  # Get the prefix url for shows
  def fan_prefix_url
    return Emails.url + "/fan/"
  end
  
  # Return the URL prefix *before* a band name
  def photo_prefix_url
    return Emails.url + "/"
  end
  
  # URL prefix for fan private
  def fan_private_prefix_url
    Emails.url + "/fans/"
  end
  
  def email_signoff_plain
    str = ""
    str << "rock on,\n"
    str << "the tourb.us team"
    return str
  end
  
  # The closing part of emails we send that is
  # used in many emails.
  def email_signoff
    str = ""
    str << "<p>rock on,<br/>"
    str << "the <a href='http://tourb.us?utm_source=footersignoff&utm_medium=email'>tourb.us</a> team"
    # Rotate an ad
    str << "<br/>----<br/>"
    str << "have a blog? share your shows! <a href='http://tourb.us/badge?utm_source=badgefooter&utm_medium=email'>http://tourb.us/badge</a>"
    return str
  end
  
end