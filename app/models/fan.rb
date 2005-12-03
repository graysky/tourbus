require_dependency "password_protected"

class Fan < ActiveRecord::Base
  include ActiveRecord::Acts::PasswordProtected
  acts_as_password_protected
  file_column :logo, :magick => { :geometry => "200x300>" }
  
  # TODO No spaces in name
  validates_presence_of :name, :contact_email
  validates_uniqueness_of :name, 
                          :message => "Sorry, that name has already been taken."
                          
  # Creates and sets the confirmation code. DOES NOT save the record.
  # Requires that that object already be populated with required fields
  def create_confirmation_code
    self.confirmation_code = Hash.hashed(self.name + rand.to_s)
    return self.confirmation_code
  end
  
  # Returns the band if it was authenticated.
  # May return an unconfirmed band, the caller must check.
  def self.authenticate(login, password)
    fan = find_by_name(login)
    return nil if fan.nil?
    return find(:first, 
                :conditions => ["confirmed = 1 and name = ? and salted_password = ?", login, Fan.salted_password(fan.salt, Hash.hashed(password))])
  end
end
