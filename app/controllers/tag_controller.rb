# Controller to create tags
class TagController < ApplicationController

  # Creates a new tag on the object that matches the id and type
  # id => id of the item being tagged
  # type => the Tag type to create
  # tag => the tag name
  def create
  
    id = params[:id]
    tag_type = params[:type]
    tag_name = params[:tag]
    # Pass thru whether to show the delete action for the tag
    show_delete = params[:show_delete]
    
    # Note the type comes in as a string but needs
    # to be converted for equality testing.
    obj = lookup_object(tag_type.to_i, id)
    
    # Assumes the object includes the tagging mixin
    saved_tags = obj.add_tag(tag_name, tag_type)
    
    # Need to save the object so the tag is indexed
    obj.save
    
    # Returns array of saved tag names, like ["tag1", "tag2"]
    if saved_tags.nil? or saved_tags.empty?
      # TODO Handle error case
    end
    
    ## TODO Handle multiple tags added at once
    tag = Tag.find_by_name( saved_tags[0] )
    
    # Render the new tag name
    render(
		:partial => "shared/tag",
		:locals =>
			{
			:tag => tag,
			:type => tag_type,
			:id => id,
			:show_delete => show_delete,
			})
  
  end
  
  # Removes a tag from the given object
  def delete
    
    id = params[:id] # ID of the tagged object 
    tag_id = params[:tag_id]
    tag_type = params[:type]
    
    # Note the type comes in as a string but needs
    # to be converted for equality testing.
    obj = lookup_object(tag_type.to_i, id)
    
    obj.delete_tag(tag_id)
    
    if obj.save  
      render :text => "#{tag_id}"
    else
      # TODO Handler error
    end
    
  end

  # Called to auto-complete tag name
  # Assumes param named :tag
  def auto_complete
    
    search = params[:tag]
    
    tags = Tag.find(:all,
             :conditions => "name LIKE '#{search}%'",
             :limit => 10)

    # Show the tag hits in a drop down box
    render(
	:partial => "shared/tag_hits", 
	:locals => 
		{
		:tags => tags, 
		}) 
    
  end
  
  private
  
  # Convert from the type of object being tagged
  # to the actual object
  # ctype => type of the tag
  # id => id of the object to lookup
  def lookup_object(ctype, id)
  
    if ctype == Tag.Band
      return Band.find_by_id(id)
    elsif ctype == Tag.Venue
      return Venue.find_by_id(id)
    elsif ctype == Tag.Photo
      return Photo.find_by_id(id)
    elsif ctype == Tag.Show
      return Show.find_by_id(id)
    elsif ctype == Tag.Fan
      return Fan.find_by_id(id)
    else
      flash.now[:error] = "Tag on this type is not supported"
    end
  
  end

end
