#!c:/dev/ruby/bin/ruby
require 'net/pop'
require File.dirname(__FILE__) + '/../config/environment'

# TODO Need to be able to launch this from script/runner

# Script that uses POP3 to check email for message for the app
# Inspired by:
# http://wiki.rubyonrails.com/rails/pages/HowToReceiveEmailsWithActionMailer

logger = RAILS_DEFAULT_LOGGER

logger.info "Running Mail Importer..."

# Hacked for testing. 
# Should be the address that all email for the domain is funnelled to.
Net::POP3.start("mail.figureten.com", nil, "tourbus", "freeman00") do |pop|

  if pop.mails.empty?
    logger.info "NO MAIL" 
  else
    pop.mails.each do |email|

      begin
        logger.info "receiving mail..."
        
        # Send the email to the MailReader which will process the email
        MailReader.receive(email.pop)
        
        # TODO Change to delete the email
        # email.delete
        
      rescue Exception => e
        err = "Error receiving email at " + Time.now.to_s + "::: " + e.message
        logger.error( err )
        p err
      end

    end
  end
end
logger.info "Finished Mail Importer." 