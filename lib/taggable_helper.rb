module TaggableHelper
  def comma_separated_tag_names
    return tag_names.join(",")
  end
  
  def comma_separated_tag_names=(tags)
    tags_array = tags.split(",").each { |tag| tag.strip! }
    tag(tags_array, :clear => true)
  end
end