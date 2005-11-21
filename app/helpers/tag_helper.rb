# Helper for doing tagging operations
module TagHelper

  # Custom auto-complete field for tags that allows multiple fields per page with unique ids
  # Requires an id to make each text field unique
  # Similar to text_field_with_auto_complete in javascript_helper
  def tag_field_with_auto_complete(id, tag_options = {}, completion_options = {})
    (completion_options[:skip_style] ? "" : auto_complete_stylesheet) +
    text_field_tag("tag_#{id}", nil, { :name => "tag", :autocomplete => "off" }.merge!(tag_options)) +
    content_tag("div", "", :id => "tag_#{id}_auto_complete", :class => "auto_complete") +
    auto_complete_field("tag_#{id}", { :url => { :action => "auto_complete_for_tag" } }.update(completion_options))
  end

end