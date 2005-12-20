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
    
    # Note the type comes in as a string but needs
    # to be converted for equality testing.
    obj = lookup_object(tag_type.to_i, id)
    
    # Assumes the object includes the tagging mixin
    obj.add_tag(tag_name, tag_type)
    
    # Save the object so the new tag will get indexed for search
    obj.save
    
    # Return the tag name 
    render :text => tag_name
  
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
  
    if ctype == Tag.Genre or ctype == Tag.Influence or ctype == Tag.Misc
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
      flash[:notice] = "Tag on this type is not supported"
    end
  
  end

end
