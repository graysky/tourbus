require_dependency 'emails'

# Base class for all our ActionMailers
class BaseMailer < ActionMailer::Base

  # Get the prefix url for shows
  def show_prefix_url
    return Emails.url + "/show/"
  end

end