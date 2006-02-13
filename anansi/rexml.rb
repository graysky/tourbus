module REXML
  class Element

    def find_element( content)
      @elements.each("//") do |elem|
        next if elem.text.nil?
        return elem if elem.texts.join(" ").include?(content)
      end
      
      return nil
    end
    

    def find_parent(tag)
      child = self
      while child != self.root
        parent = child.parent
        return parent if parent.name == tag
        child = parent
      end
    end
    
    def recursive_text
      text = ''
      @children.each do |e|
        if e.class == Text
          text << e.to_s
        else
          text << e.recursive_text
        end
      end
      
      return text
    end
    
  end
end
