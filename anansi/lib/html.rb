# This is not terribly useful yet
module HTML
  def self.strip_tags(html)
    html.gsub(/<(#{TAG_REGEXP})(.|\n)*?>/, ' ')
  end
  
  # TODO Might want to replace with rails version
  def self.strip_all_tags(html)
    html.gsub(/<(\w|\/)+(.|\n)*?>/, ' ')
  end
  
  private
  
  TAG_REGEXP = %w{ img font tbody option script style head }.map { |tag| "#{tag}|\\/#{tag}" }.join("|")
end
