require_dependency 'emails'

# Base class for all our ActionMailers
class BaseMailer < ActionMailer::Base

  # Get the prefix url for shows
  def show_prefix_url
    return Emails.url + "/show/"
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