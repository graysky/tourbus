# Reads new mail that is sent in and handle it
class MailReader < ActionMailer::Base

  # Handles new mail as it is given the Mailman
  # The email obj is a TMail::Mail object, part of Act. Mailer
  # Rails book also has some docs on pg. 418.
  # Found that for TMail, looking through facade.rb in the AM dir is helpful
  def receive(email)

    # Need to figure out the best way to extract fields  
    date = email.date
    subject = email.subject
    from_name = email.friendly_from
    from_addr = email.from[0] # Could be more than 1?
    body = email.body
    # Array of TO addresses, need to make sure we just get the TB one.
    to_addrs = email.to_addrs
    
    p "Mail received at: #{date}"
    p "Received email from: #{from_name} (#{from_addr})"

    # The list of 
    to_addrs.each do |to|
      p "Sent to #{to}"
    end

    p "Subject: #{subject}"
    p "Body: #{body}"
     

    if email.has_attachments?
      email.attachments.each do |attachment|
        # Presumably this would be a photo
        p "Attachment name: #{attachment.original_filename}"
        p "Attachment content-type: #{attachment.content_type}"
      end
    end
    
    print "\n\n"
    
  end
  
end
