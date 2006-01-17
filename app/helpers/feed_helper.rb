# Helper for publishing RSS feeds.
module FeedHelper

  # Format an individual RSS 2.0 item for an item in the feed
  def xml_for_item(xml, item)
  
    # Dispatch to the correct type of helper
    if item.nil?
      # Do nothing
    elsif item.kind_of?(Comment)
      xml_for_comment(xml, item)
      
    elsif item.kind_of?(Show)
      xml_for_show(xml, item)
      
    elsif item.kind_of?(Photo)
      xml_for_photo(xml, item)
    end
  
  end

  private
    
  # Format a Show
  def xml_for_show(xml, show)
     
     xml.title("#{show.title}") 
     xml.description("#{show.description}")
  end
  
  # Format a Comment
  def xml_for_comment(xml, comment)
  
    xml.title("Comment at #{comment.created_on}")
    xml.description( comment.body )
  end
  
  # Format a Photo
  def xml_for_photo(xml, photo)

    s = "<img src=\"" + public_photo_url(photo, "preview") + "\"/>"
    
    s << "<br/>#{photo.description}"

    xml.description( s )
  end

end