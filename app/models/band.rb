require_dependency "hash"
require_dependency "password_protected"
require "taggable"
require "tagging"

class Band < ActiveRecord::Base
  include ActiveRecord::Acts::PasswordProtected
  include Tagging
  acts_as_password_protected
  acts_as_taggable :join_class_name => 'TagBand'
  has_and_belongs_to_many :shows, :order => "date ASC"
  has_many :tours
  file_column :logo
  
  validates_presence_of :name, :band_id
  validates_uniqueness_of :band_id, 
                          :message => "Sorry, that band name has already been taken."
                          
  # TODO Not working?                        
  validates_presence_of :password, :if => :validate_password?
  validates_confirmation_of :password, :if => :validate_password?
  
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
    # NOTE: Keep this in sync with the implementation in signup_band.rhtml!
    id = name.gsub(/[^\w|\d|_|.|-]/, '').downcase
  end
  
  # Add Genre tags
  def genre_tag_names=(tags)
    add_tags(tags, Tag.Genre)
  end

  # Get just the Genre tags
  def genre_tag_names
    get_tags(Tag.Genre)
  end
  
  # Add Influence tags
  def influence_tag_names=(tags)
    add_tags(tags, Tag.Influence)
  end

  # Get just the Influence tags
  def influence_tag_names
    get_tags(Tag.Influence)
  end
  
end
