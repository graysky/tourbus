# Controller to create and fetch comments
class CommentController < ApplicationController

  # Create a new comment.
  # Params:
  # type => type of comment (show, band, etc.)
  # id => id of the object to comment on
  # comment => the comment fields
  def create
  
    comment = Comment.new(params[:comment])

    type = params[:type]
    id = params[:id]
    
    # Create the association between comment and object
    # Note the type comes in as a string but needs
    # to be converted for equality testing.
    case type.to_i
      when Comment.Show then comment.show = Show.find_by_id(id)
      when Comment.Band then comment.band = Band.find_by_id(id)
      when Comment.Photo then comment.photo = Photo.find_by_id(id)
      when Comment.Venue then comment.venue = Venue.find_by_id(id)
      when Comment.Fan then comment.fan = Fan.find_by_id(id)
    end

    # Determine who posted the comment    
    comment.created_by_band = logged_in_band if logged_in_band
    comment.created_by_fan = logged_in_fan if logged_in_fan
    comment.save
    
    ### TODO Need to handle failed validation when adding comments!
    
    # Render the new comment
    render(
		:partial => "shared/comment",
		:locals =>
			{
			:comment => comment,
			})
  end

  private
    
  # Set the type of object being commented on
  # ctype => type of the comment
  # id => id of the object to lookup
  # comment => the comment to attach
  def set_comment_assoc(ctype, id, comment)
  
    case ctype
      when Comment.Show then comment.show = Show.find_by_id(id)
      when Comment.Band then comment.band = Band.find_by_id(id)
      when Comment.Photo then comment.photo = Photo.find_by_id(id)
      when Comment.Venue then comment.venue = Venue.find_by_id(id)
      when Comment.Fan then comment.fan = Fan.find_by_id(id)
    end
  
  end
end
