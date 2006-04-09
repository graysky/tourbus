# Mailer for signing up for the beta
class BetaMailer < BaseMailer

  # User signed up for the beta
  def signup(email_addr, sent_at = Time.now)
    @subject    = '[tourb.us] Launch Signup'
    @recipients = Emails.feedback
    @from       = Emails.from
    @sent_on    = sent_at
    @headers    = {}
    content_type "text/html"
    
    @body["sent"] = "#{sent_at}"
    @body["email"] = email_addr
  end
end
