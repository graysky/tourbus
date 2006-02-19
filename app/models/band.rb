require_dependency "hash"
require_dependency "password_protected"
require_dependency "searchable"
require 'ferret'
require_dependency "taggable"
require_dependency "tagging"
require_dependency "address"

class Band < ActiveRecord::Base
  include ActiveRecord::Acts::PasswordProtected
  include FerretMixin::Acts::Searchable
  include Address::ActsAsLocation
  include Tagging
  include Ferret
  
  acts_as_password_protected
  acts_as_taggable :join_class_name => 'TagBand'
  has_and_belongs_to_many :shows, :order => "date ASC"
  has_and_belongs_to_many :fans
  has_many :photos, :order => "created_on DESC"
  has_many :comments, :order => "created_on ASC"
  file_column :logo, :magick => { :geometry => "240x320>" }
  has_one :upload_addr
  acts_as_searchable
  
  validates_uniqueness_of :uuid # just in case
  validates_presence_of :name
  validates_uniqueness_of :short_name, 
                          :message => "Sorry, that band public page has already been taken."
                          
  validates_uniqueness_of :contact_email, 
                          :message => "Sorry, someone has already signed up with that email address.",
                          :if => :validate_unique_email?
                          
                                         
  validates_presence_of :password, :if => :validate_password?
  validates_length_of :password, :minimum => 4, :if => :validate_password?
  validates_confirmation_of :password, :if => :validate_password?
  
  def validate
    if short_name.blank? or short_name != Band.name_to_id(short_name)
      errors.add_to_base("Invalid public page address. A valid address contains no spaces or punctuation other than \".\", \"-\", or \"_\"")
    end
    
    if claimed? && contact_email.blank?
      errors.add(:contact_email, "must be a valid email address.")
    end
  end
  
  def play_show(show, can_edit = true)
    show.bands << self
  end

  def validate_unique_email?
    super and self.claimed?
  end
  
  # Returns the band if it was authenticated.
  # May return an unconfirmed band, the caller must check.
  def self.authenticate(login, password)
    band = find_by_short_name(login)
    return nil if band.nil?
    return find(:first, 
                :conditions => ["confirmed = 1 and short_name = ? and salted_password = ?", login, Band.salted_password(band.salt, Hash.hashed(password))])
  end
 
  # Creates and sets the confirmation code. DOES NOT save the record.
  # Requires that that object already be populated with required fields
  def create_confirmation_code
    self.confirmation_code = Hash.hashed(short_name + rand.to_s)
    return self.confirmation_code
  end
  
  # Get a band id given a band name
  # The band id is the band name with whitespace and punctuation stripped out, all lowercase
  def self.name_to_id(name)
    # Remove anything that's not a letter, number or selected punctuation
    # NOTE: Keep this in sync with the implementation in signup_band.rhtml!
    id = name.gsub(/[^\w|\d|_|.|-]/, '').downcase
  end
  
  # Add Band tags
  def band_tag_names=(tags)
    add_tags(tags, Tag.Band)
  end

  # Get just the Band tags
  def band_tag_names
    get_tags(Tag.Band)
  end
  
  # The upload email address, fully qualified like "down42tree@tourb.us"
  def upload_email_addr()
    return upload_addr.address + "@" + UploadAddr.Domain
  end
  
  protected
  
  # Index band-specific fields
  def add_searchable_fields
    fields = []
    fields << Document::Field.new("latitude", self.latitude, Document::Field::Store::YES, Ferret::Document::Field::Index::UNTOKENIZED)
    fields << Document::Field.new("longitude", self.longitude, Document::Field::Store::YES, Ferret::Document::Field::Index::UNTOKENIZED)
  end
end
