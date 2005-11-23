# Login functionality for any model class that can login to the system
# Requires certain attributes: salt and salted_password.
module ActiveRecord
  module Acts
    module PasswordProtected
    
      def self.append_features(base)
        super
        base.extend(ClassMethods)  
      end
      
      # In memory attributes to ease password manipulation
      attr_accessor :new_password, :password, :password_confirmation
      
      module ClassMethods
        def acts_as_password_protected(options = {})
          class_eval do
            include ActiveRecord::Acts::PasswordProtected::InstanceMethods
            
            after_save '@new_password = false'
            after_validation :crypt_password
          end
        end
        
        def salted_password(salt, hashed_password)
          return Hash.hashed(salt + hashed_password)
        end
      end
      
      module InstanceMethods
        def validate_password?
          return @new_password
        end
        
        def initialize(attributes = nil)
          super
          @new_password = false
        end
        
        # Change the password. DOES NOT save the record.
        def change_password(pass, confirm = nil)
          self.password = pass
          self.password_confirmation = confirm.nil? ? pass : confirm
          @new_password = true
        end
        
        # Crypt the current password if the password has changed
        def crypt_password
          if @new_password
            self.salt = Hash.hashed("salt-#{Time.now}")
            self.salted_password = Band.salted_password(self.salt, Hash.hashed(@password))
          end
        end  
      end
    end
  end  
end