module ActsAsBackground

  def self.append_features(base)
    super
    base.extend(ClassMethods)
  end
  
  module ClassMethods
  
    def background(method, options = {})
      RailsCron.create_singleton(self, method, options)
    end
  end
end