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

  # G&M alias
  def self.gm
    return "gm@" + domain
  end
  
  # Feedback address
  def self.feedback
    return "feedback@" + domain
  end
  
  # "From" address for sending emails like reminders
  def self.from
    return "robot@" + domain
  end
  
  # A spam address for testing
  def self.spam
    return "spam@" + domain
  end

end