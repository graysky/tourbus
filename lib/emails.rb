# List of email addresses
class Emails

  # Base URL for tourbus
  def self.url
    return "http://" + domain
  end

  # Return our domain name => "tourb.us"
  def self.domain
    return "tourb.us"
  end

  # Helper to format a mailto link to specified address
  def self.mailto(addr)
    "<a href=\"mailto:#{addr}\">#{addr}</a>"
  end

  # Help address
  def self.help
    return "help@" + domain
  end
  
  # Feedback address
  def self.feedback
    return "feedback@" + domain
  end
  
  # "From" address for sending emails like reminders
  def self.from
    # TODO Could also use "noreply", "hi" or "yo" instead - set an auto-responder too
    return "tourb.us robot <robot@" + domain + ">"
  end

end