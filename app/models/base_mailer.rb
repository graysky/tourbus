require_dependency 'emails'

# Base class for all our ActionMailers
class BaseMailer < ActionMailer::Base

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
  def fan_private_prefix_url(fan)
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
    str << "the <a href='http://tourb.us'>tourb.us</a> team</p>"
    return str
  end
  
end