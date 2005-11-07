require_dependency "hash"
require "taggable"

class Band < ActiveRecord::Base
  acts_as_taggable :join_class_name => 'TagBand'
  has_and_belongs_to_many :shows
  has_many :tours
  file_column :logo
  
  # In memory attributes to ease password manipulation
  attr_accessor :new_password, :password, :password_confirmation
  
  validates_presence_of :name, :contact_email, :band_id, :zipcode
  validates_uniqueness_of :band_id, 
                          :message => "Sorry, that band name has already been taken."
  validates_presence_of :password, :if => :validate_password?
  validates_confirmation_of :password, :if => :validate_password?
  
  # Types of tags
  GENRE_TYPE = 0
  INFLUENCE_TYPE = 1
  MISC_TYPE = 2
  
  # Getter for type
  # TODO Is there a better way to do this? Should I define the types as class statics
  # instead? What is the Ruby way of doing this?
  def self.GENRE_TYPE
    GENRE_TYPE
  end
  
  def self.INFLUENCE_TYPE
    INFLUENCE_TYPE
  end
  
  def self.MISC_TYPE
    MISC_TYPE
  end
  
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
  
  # Add a new tag of the given type
  def add_tag(tag_type, tag_name)
    tags_array = [tag_name]
    tag(tags_array, :attributes => { :tag_type => tag_type } ) #:clear => true)
  end
    
  # Add Genre tags
  def genre_tag_names=(tags)
    add_tags(tags, GENRE_TYPE)
  end

  # Get just the Genre tags
  def genre_tag_names
    get_tags(GENRE_TYPE)
  end
  
  # Add Influence tags
  def influence_tag_names=(tags)
    add_tags(tags, INFLUENCE_TYPE)
  end

  # Get just the Influence tags
  def influence_tag_names
    get_tags(INFLUENCE_TYPE)
  end
  
  protected
  
  # Get the list of tags of the given type
  def get_tags(tag_type)

    # Pull out array just of tags of specified type
    typed_tags = tags.select { |itag| itag.tag_type == tag_type }

	typed_tags
  end
  
  # Add the following tags of the specified type.
  def add_tags(tags, tag_type)
    tags_array = tags.split(",").each { |tag| tag.strip! }
    tag(tags_array, :attributes => { :tag_type => tag_type } ) #:clear => true)
  end
  
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
