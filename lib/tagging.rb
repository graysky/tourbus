# Mixin for helping with objects that are tagable.
# Assumes a var in scope named "tags" that is the collection of tags
# from the taggable mixin.
module Tagging

  # TODO Need to handle tag that already exists

  # Add a new tag of the given type
  def add_tag(tag_name, tag_type)
    
    tags_array = [tag_name]
    tag(tags_array, :attributes => { :tag_type => tag_type } )
  end
    
  # Add the following tags of the specified type.
  # Note the strange name because "add_tags" is taken by AR.
  # Aargh, this was done when I was just starting with ruby and it shows.
  def apply_tags(tags, tag_type)
  
    # Split the list of possible tags at commas
    tags_array = tags.split(",").each { |tag| tag.strip! }
    
    # Apply the tags
    tag(tags_array, :attributes => { :tag_type => tag_type } )
  end

  # Get the list of tags of the given type
  def get_tags(tag_type)

    # Pull out array just of tags of specified type
    typed_tags = tags.select { |itag| itag.tag_type == tag_type }
    
    return typed_tags
  end
  
  # Delete a tag from this object
  # Note: Does not actually delete the Tag object
  # just the association
  def delete_tag(tag_id)
  
    delete_tag = []
    # The tag_id is the TagBand.id (for example) -- NOT the Tag.id
    delete_tag = tags.select {|x| x.id == tag_id.to_i }
    
    if delete_tag.empty?
      # Error - couldn't find tag to delete  
    else
      # Delete the join table object
      delete_tag[0].destroy
    end
  end

end