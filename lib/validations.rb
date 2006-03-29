# Custom validations
module ActiveRecord
  module Validations
    module ClassMethods
    
      def validate_not_reserved(*attrs)
        configuration = {}
        configuration.update(attrs.pop) if attrs.last.is_a?(Hash)
        
        raise ArgumentError, 'Missing :message key' unless configuration[:message]
        raise ArgumentError, 'Missing :words key' unless configuration[:words]
        
        words = configuration[:words]
        validates_each(attrs, configuration) do |record, attr, value|
          record.errors.add('', configuration[:message]) if words.include?(value)
        end
      end
      
    end
  end
end