require_dependency "hash"

class Band < ActiveRecord::Base
  has_and_belongs_to_many :tags
  has_many :shows
  
  # In memory attributes to ease password manipulation
  attr_accessor :new_password, :password, :password_confirmation
  
  validates_presence_of :name, :contact_email, :band_id, :zipcode
  validates_uniqueness_of :band_id
  validates_presence_of :password, :if => :validate_password?
  validates_confirmation_of :password, :if => :validate_password?
  
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
  
  # Creates and sets the confirmation code. DOES NOT save the record.
  # Requires that that object already be populated with required fields
  def create_confirmation_code
    self.confirmation_code = Hash.hashed(band_id + rand.to_s)
    return self.confirmation_code
  end
  
  # Get a band id given a band name
  # The band id is the band name with whitespace and punctuation stripped out.
  def self.band_name_to_id(name)
    # TODO
  end
  
  protected
 
  def validate_password?
    return @new_password
  end
  
  # Crypt the current password if the password has changed
  def crypt_password
    if @new_password
      self.salt = Hash.hashed("salt-#{Time.now}")
      self.salted_password = salted_password(salt, Hash.hashed(@password))
    end
  end
  
  def salted_password(salt, hashed_password)
    return Hash.hashed(self.salt + hashed_password)
  end
  
  # ActiveRecord hooks
  after_save '@new_password = false'
  after_validation :crypt_password
  
end
