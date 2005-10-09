require_dependency "hash"
require "taggable"
require_dependency "taggable_helper"

class Band < ActiveRecord::Base
  acts_as_taggable
  include TaggableHelper
  has_and_belongs_to_many :shows
  has_many :tours
  
  # In memory attributes to ease password manipulation
  attr_accessor :new_password, :password, :password_confirmation
  
  validates_presence_of :name, :contact_email, :band_id, :zipcode
  validates_uniqueness_of :band_id, 
                          :message => "Sorry, that band name has already been taken."
  validates_presence_of :password, :if => :validate_password?
  validates_confirmation_of :password, :if => :validate_password?
  
  def initialize(attributes = nil)
    super
    @new_password = false
  end
  
  def play_show(show, can_edit = true)
    shows.push_with_attributes(show, :can_edit => can_edit)
  end
  
  # Returns the band if it was authenticated.
  # May return an unconfirmed band, the caller must check.
  def self.authenticate(login, password)
    band = find_by_band_id(login)
    return nil if band.nil?
    return find(:first, 
                :conditions => ["confirmed = 1 and band_id = ? and salted_password = ?", login, Band.salted_password(band.salt, Hash.hashed(password))])
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
  # The band id is the band name with whitespace and punctuation stripped out, all lowercase
  def self.name_to_id(name)
    # Remove anything that's not a letter, number or selected punctuation
    id = name.gsub(/[^\w|\d|_|.|-]/, '').downcase
  end
  
  protected
 
  def validate_password?
    return @new_password
  end
  
  # Crypt the current password if the password has changed
  def crypt_password
    if @new_password
      self.salt = Hash.hashed("salt-#{Time.now}")
      self.salted_password = Band.salted_password(self.salt, Hash.hashed(@password))
    end
  end
  
  def self.salted_password(salt, hashed_password)
    return Hash.hashed(salt + hashed_password)
  end
  
  # ActiveRecord hooks
  after_save '@new_password = false'
  after_validation :crypt_password
  
end
