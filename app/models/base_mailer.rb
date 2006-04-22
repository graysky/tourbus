require_dependency 'emails'

# Base class for all our ActionMailers
class BaseMailer < ActionMailer::Base

  ## This is lame - better to share across with ActiveController helpers
  
  # Return the URL prefix *before* a band name
  def band_prefix_url
    return Emails.url + "/"
  end

  # Get the prefix url for shows
  def show_prefix_url
    return Emails.url + "/show/"
  end
  
  # Return the URL prefix *before* a band name
  def photo_prefix_url
    return Emails.url + "/"
  end
  
  # The closing part of emails we send that is
  # used in many emails.
  def email_signoff
    str = ""
    str << "<p>thanks,<br/>"
    str << "the <a href='http://tourb.us'>tourb.us</a> team</p>"
    return str
  end
  
end