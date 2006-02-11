require 'net/pop'
require 'iconv'

# Need to install iconv to stop all the whining about charset conversions. Instructions
# http://wiki.rubyonrails.com/rails/pages/iconv

# Reads new mail that is sent in and handle it
class MailReader < ActionMailer::Base

  # Handles new mail as it is given to.
  # Returns true if the mail should be deleted, false otherwise.
  # The email obj is a TMail::Mail object, part of Act. Mailer
  # Rails book also has some docs on pg. 418.
  # Found that for TMail, looking through facade.rb in the AM dir is helpful
  def receive(email)

    # Need to figure out the best way to extract fields  
    date = email.date
    subject = email.subject
    from_name = email.friendly_from
    from_addr = email.from[0] # Could there be more than 1?
    body = email.body
    to_addrs = email.to_addrs
    
    p "Mail received at: #{date}"
    p "Received email from: #{from_name} (#{from_addr})"
    p "Subject: #{subject}"
    p "Body: #{body}"

    # If the email contains a valid "to" address
    valid_to_addr = false
    # A valid address that TB listens to
    sent_to_addr = nil
    
    # The list of TO addresses. 
    # Handle that there could be more than one, like Flickr and TB ;-)
    to_addrs.each do |to|
      
      # Simple spam filtering, making sure the email was sent to a valid-looking address
      if UploadAddr.valid_address?(to.to_s)
        # Remember that this is a valid-looking email
        valid_to_addr = true
        sent_to_addr = to.local.to_s
      end
    end
    
    # Ensure there is at least 1 valid TO address, namely a (likely) real account
    return true if !valid_to_addr

    attachments = []
    
    if email.has_attachments?
      email.attachments.each do |attachment|
        p "Attachment name: #{attachment.original_filename}"
        # Add to the list of attachments
        attachments << attachment
      end
    end
    
    # Rip off the "@tourb.us" part of the email address
    domain = "@" + UploadAddr.Domain
    sent_to_addr.sub!(domain, "")
    
    success = false

    if attachments.empty?
      # Create new comment
      success = add_comment(sent_to_addr, subject, body)
    else
      # Upload a photo
      # TODO Expand to handle multiple photos
      success = add_photo(sent_to_addr, subject, body, attachments[0])
    end
    
    print "\n\n"
    return success
  end
  
  # Add a new comment from the owner of this special address
  # sent_to_addr => prefix of email address (ex. "down42tree")
  # Return true if the comment was successfully added, false otherwise
  def add_photo(sent_to_addr, subject, body, image)
    
    # See if the TO address is valid
    upload_addr = UploadAddr.find_by_address(sent_to_addr)
    
    if upload_addr.nil?
      p "Upload address not found!"
      logger.warn "Upload address not found!"
      return false
    end
    
    # Parse subject line to get object to attach photo to
    obj = parse_subject(subject)
    
    # TODO Make sure content_type is ok
    # {attachment.content_type}
    
    # Bail out if no real object was found
    return false if obj.nil?
    
    # The photo to fill in
    photo = Photo.new()
    
    # The the object type for the comment
    if obj.instance_of?(Show)
      photo.show = obj
    elsif obj.instance_of?(Band)
      photo.band = obj
    elsif obj.instance_of?(Venue)
      photo.venue = obj
    end
    
    # Set the in-memory image for the photo, it will be copied
    photo.file = image
    
    # TODO Clean up the body of the message. Pull out "Cingular" sig and crap.
    photo.description = body
    
    # Determine who the comment is from    
    if !upload_addr.fan.nil?
      photo.created_by_fan_id = upload_addr.fan.id
    elsif !upload_addr.band.nil?
      photo.created_by_band_id = upload_addr.band.id
    else
      return false
    end
    
    recipients = upload_addr.owner.contact_email
    
    # Save the photo and notify people
    if photo.save
      PhotoMailer.deliver_notify_photo(photo, recipients)
      return true
    else
      return false
    end
  end
  
  # Add a new comment from the owner of this special address
  # sent_to_addr => prefix of email address (ex. "down42tree")
  # Return true if the comment was successfully added, false otherwise
  def add_comment(sent_to_addr, subject, body)

    # See if the TO address is valid
    upload_addr = UploadAddr.find_by_address(sent_to_addr)
    
    if upload_addr.nil?
      p "Upload address not found!"
      logger.warn "Upload address not found!"
      return false
    end
    
    # Parse subject line to get object to comment on
    obj = parse_subject(subject)
    
    # Bail out if no real object was found
    return false if obj.nil?
    
    # The comment to fill in
    comment = Comment.new()

    # The the object type for the comment
    if obj.instance_of?(Show)
      comment.show = obj
    elsif obj.instance_of?(Band)
      comment.band = obj
    elsif obj.instance_of?(Venue)
      comment.venue = obj
    end
    
    # TODO Clean up the body of the message. Pull out "Cingular" sig and crap.
    comment.body = body
    
    # Determine who the comment is from   
    if !upload_addr.fan.nil?
      comment.created_by_fan_id = upload_addr.fan.id
    elsif !upload_addr.band.nil?
      comment.created_by_band_id = upload_addr.band.id
    else
      return false
    end
    
    # TODO Change this to actually notify the folks who care about this comment/photo 
    recipients = upload_addr.owner.contact_email
    
    # Save the comment and notify people
    if comment.save
      # Notify the poster 
      CommentMailer.deliver_notify_comment(comment, recipients)
      return true
    else
      return false
    end
  end
  
  # Check for POP3 email and pass off to for further handling.
  # This can be run like:
  # ruby script/runner MailReader.check_email
  # Inspired by:
  # http://wiki.rubyonrails.com/rails/pages/HowToReceiveEmailsWithActionMailer
  def self.check_email()
  
    # Previous hack for testing:
    # "tourbus@figureten.com tourbus/freeman00" - 1 address 
    # "tb@figureten.com m9882612/freeman00" - catch-all address
    #
    # Should be the address that all email for the domain is funnelled to.
    Net::POP3.start("mail.tourb.us", nil, "incoming+tourb.us", "bighit") do |pop|
      
      if pop.mails.empty?
        logger.info "No Mail at #{Time.now}"
        p "No Mail at #{Time.now}"
      else
        pop.mails.each do |email|
          
          begin
            # Send the email to the MailReader which will process the email
            shouldDelete = MailReader.receive(email.pop)
            
            # Delete the email if it was successfully processed (or junk)
            email.delete if shouldDelete
            
          rescue Exception => e
            err = "Error receiving email at " + Time.now.to_s + "::: " + e.message
            logger.error( err )
            p err
          end
        end
      end
    end
  end
  
  private
  
  # Parse the subject line of an email. Returns the object referenced
  # by the format or nil. 
  # Expects the format:
  # s[how] | b[and] | v[enue] ID
  def parse_subject(subject)
  
    # Allow whitespace at beginning or between obj and ID.
    re_s = /^\s*(s|show)\s*(\d+)/i
    re_b = /^\s*(b|band)\s*(\d+)/i
    re_v = /^\s*(v|venue)\s*(\d+)/i
    
    obj = nil
    
    # Try to match the various objects
    # If matches, md[1] is type, md[2] is the ID. Pickaxe pg. 70
    if md = re_s.match(subject)
      id = md[2].to_i
      obj = Show.find_by_id(id)
      
    elsif md = re_b.match(subject)
      id = md[2].to_i
      obj = Band.find_by_id(id)

    elsif md = re_v.match(subject)
      id = md[2].to_i
      obj = Venue.find_by_id(id)
    else
      # Did not match any of the objects. Bail out
      return nil
    end
    
    return obj
  end
  
end
