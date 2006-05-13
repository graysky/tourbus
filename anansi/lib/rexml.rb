# Helper methods for REXML
module REXML
  class Element

    # Find The first element with text that contains the given content,
    # which can be an array of strings or a string
    def find_element(content)
      self.each_element do |elem|
        if not elem.text.nil?
          str = elem.texts.join(" ")
          if content.is_a?(String)
            return elem if str.include?(content)
          elsif content.is_a?(Array)
            content.each { |s| return elem if str.include?(s) }
          end
        end
        
        val = elem.find_element(content)
        return val if val
      end
      
      return nil
    end
    
    # Find the parent of this node with the given tag
    def find_parent(tag)
      child = self
      while child != self.root
        parent = child.parent
        return parent if parent.name == tag
        child = parent
      end
    end
    
    # Get all text from this node down
    def recursive_text
      text = ''
      @children.each do |e|
        if e.class == Text
          text << e.to_s + " "
        else
          text << e.recursive_text
        end
      end
      
      return text
    end
    
    # Find an element with the given name text
    def find_node_by_text(type, text = nil)
      @children.each do |e|
        next if e.is_a?(Text)
        return e if e.name == type and (text.nil? or e.text == text)
        node = e.find_node_by_text(type, text)
        return node if node
      end
      
      nil
    end
    
  end
end
