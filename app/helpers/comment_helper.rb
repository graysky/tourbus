# Helper for displaying comments. Needs to be included in any controller that
# will display comments.
module CommentHelper

  # Create the table to hold the comments
  def comments_table(comments, max_comments)
  
    html = "<table class='comments_table' id='comment-list'>\n"
    
    if comments.nil? or comments.empty?
      # Write out the first row for use by the javascript updating functions
      html << "<tr></tr></table>"
      return html
    end
    
    # TODO Need to handle even/odd rows?
    for comment in comments
      html << comment_row(comment)
    end
    
    html << "\n</table>"
  end
  
  # Assumes it is being added to an existing table
  def comment_row(comment)
    
    html = "\n<tr><td>"
    
    # Format the posted by line
    from = truncate(comment.created_by_name, 16)
    from_url = public_url_for_creator(comment)
    # Format date as words
    posted_at = time_ago_in_words(comment.created_on)
    
    # Format anchor for permalink like "comment#3"
    anchor = "<a name='comment#{comment.id}'/>\n" 
    html << "<div class='comment_from'>\n"
    
    html << anchor
    html << "<a href='#{from_url}'>#{from}</a> wrote:<br/></div>\n"
    
    # Format the body of the comment
    html << "<div class='comment_body'>"
    html << simple_format( sanitize(comment.body) )
    html << "</div> <br/>\n"
    
    permalink = "( <a href='#comment#{comment.id}'>permalink</a> )" 
    html << "<div class='comment_post'>posted #{posted_at} ago #{permalink}</div>"
    html << "\n</td></tr>"
  end
    
  private
  
  def public_url_for_creator(comment)
    if comment.created_by_band
      public_band_url(comment.created_by_band)
    elsif comment.created_by_fan
      public_fan_url(comment.created_by_fan)
    end
  end
    
  def even?(i)
    return i % 2 == 0
  end 
    
  def odd?(i)
    return i % 2 != 0
  end 

end
