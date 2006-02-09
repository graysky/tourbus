require_dependency "password_protected"
require_dependency "searchable"
require_dependency "address"
require_dependency "mobile_address"

# Model that describes a music fan
class Fan < ActiveRecord::Base
  include ActiveRecord::Acts::PasswordProtected
  include FerretMixin::Acts::Searchable
  include Address::ActsAsLocation
  include MobileAddress
  
  acts_as_password_protected
  file_column :logo, :magick => { :geometry => "200x300>" }
  has_many :photos, :class_name => "Photo", :foreign_key => "created_by_fan_id", :order => "created_on DESC"
  has_one :upload_addr
  has_and_belongs_to_many :bands
  has_and_belongs_to_many :shows, :order => "date ASC"
  
  validates_uniqueness_of :uuid # just in case
  
  # TODO No spaces in name
  validates_presence_of :name, :contact_email
  validates_uniqueness_of :name, 
                          :message => "Sorry, that name has already been taken."
  
  validates_uniqueness_of :contact_email, 
                          :message => "Sorry, someone has already signed up with that email address.",
                          :if => :validate_unique_email?
  
                          
  validates_presence_of :password, :if => :validate_password?
  validates_length_of :password, :minimum => 4, :if => :validate_password?
  validates_confirmation_of :password, :if => :validate_password?
  
  # Return if the band is among the fan's favorites
  def has_favorite(band)
    self.bands.detect { |fav| fav == band }
  end
  
  # Return if the show is one the fan is attending
  def is_attending(show)
    self.shows.detect { |x| x == show  }
  end
                          
  # Creates and sets the confirmation code. DOES NOT save the record.
  # Requires that that object already be populated with required fields
  def create_confirmation_code
    self.confirmation_code = Hash.hashed(self.name + rand.to_s)
    return self.confirmation_code
  end
  
  # The upload email address, fully qualified like "down42tree@mytourb.us"
  def upload_email_addr()
    return upload_addr.address + "@" + UploadAddr.Domain
  end
  
  # Returns the band if it was authenticated.
  # May return an unconfirmed band, the caller must check.
  def self.authenticate(login, password)
    fan = find_by_name(login)
    return nil if fan.nil?
    return find(:first, 
                :conditions => ["confirmed = 1 and name = ? and salted_password = ?", login, Fan.salted_password(fan.salt, Hash.hashed(password))])
  end
  
  # Get the mobile email address for this fan
  def mobile_email

    logger.info "mobile number #{mobile_number} at carrier #{carrier_type}"
    return MobileAddress::get_mobile_email(mobile_number, carrier_type)
  end  
  
  # Returns an array of reminder options in minutes
  def self.reminder_options
    
    ops = [
            ["---", 0], ["1 hour", 60], 
            ["2 hours", 120], ["3 hours", 180], ["6 hours", 360], ["12 hours", 720],
            ["1 day", 1440], ["2 days", 2880], ["3 days", 4320],
            ["7 days", 10080], ["10 days", 14400], ["14 days", 20160]
          ]
  end

end
