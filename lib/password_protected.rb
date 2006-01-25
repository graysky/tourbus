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
            
            after_validation :crypt_password
          end
        end
        
        def salted_password(salt, hashed_password)
          return Hash.hashed(salt + hashed_password)
        end
        
        # Found a snippet online with this
        # http://www.bigbold.com/snippets/posts/show/491
        def generate_password(len = 6)
            chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
            newpass = ""
            1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
            return newpass
        end
        
      end
      
      module InstanceMethods
        def validate_password?
          return @new_password
        end
        
        def validate_unique_email?
          RAILS_ENV == "production"
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
        
        def after_save
          super
          @new_password = false
        end
        
        # All this taken from the login engine code, part of Rails Engines
        def token_expired?
          self.security_token and self.token_expiry and (Time.now > self.token_expiry)
        end
    
        def generate_security_token(hours = nil)
          if not hours.nil? or self.security_token.nil? or self.token_expiry.nil? or 
              (Time.now.to_i + token_lifetime / 2) >= self.token_expiry.to_i
            return new_security_token(hours)
          else
            return self.security_token
          end
        end
        
        private
        def new_security_token(hours = nil)
          write_attribute('security_token', Hash.hashed(self.salted_password + Time.now.to_i.to_s + rand.to_s))
          write_attribute('token_expiry', Time.at(Time.now.to_i + token_lifetime(hours)))
          update_without_callbacks
          return self.security_token
        end
    
        def token_lifetime(hours = nil)
          if hours.nil?
            6 * 60 * 60
          else
            hours * 60 * 60
          end
        end
      end
    end
  end  
end