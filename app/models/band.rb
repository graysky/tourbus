# Schema as of Thu Mar 02 20:14:39 Eastern Standard Time 2006 (schema version 17)
#
#  id                  :integer(11)   not null
#  name                :string(100)   default(), not null
#  short_name          :string(100)   default(), not null
#  contact_email       :string(100)   default(), not null
#  zipcode             :string(5)     
#  city                :string(100)   default()
#  state               :string(2)     default()
#  bio                 :text          
#  salt                :string(40)    default()
#  salted_password     :string(40)    default(), not null
#  logo                :string(100)   default()
#  confirmed           :boolean(1)    
#  confirmation_code   :string(50)    default()
#  claimed             :boolean(1)    default(true)
#  created_on          :datetime      
#  page_views          :integer(10)   default(0)
#  security_token      :string(40)    
#  token_expiry        :datetime      
#  uuid                :string(40)    
#  last_updated        :datetime      
#  num_fans            :integer(11)   default(0)
#  latitude            :string(30)    
#  longitude           :string(30)    
#

require_dependency "hash"
require_dependency "password_protected"
require_dependency "searchable"
require 'uuidtools'
require_dependency "taggable"
require_dependency "tagging"
require_dependency "address"

class Band < ActiveRecord::Base
  include ActiveRecord::Acts::PasswordProtected
  include FerretMixin::Acts::Searchable
  include Address::ActsAsLocation
  include Tagging
  
  acts_as_password_protected
  acts_as_taggable :join_class_name => 'TagBand'
  has_and_belongs_to_many :shows, :order => "date ASC" #, :include => [:venue, :bands]
  has_and_belongs_to_many :upcoming_shows, :class_name => 'Show', :conditions => ["date > ?", Time.now], :order => "date ASC"
  has_and_belongs_to_many :fans
  has_many :band_relations, :foreign_key => 'band1_id', :dependent => :destroy
  has_many :related_bands, :class_name => 'Band', :through => :band_relations, :source => :band2
  has_many :photos, :order => "created_on DESC"
  has_many :comments, :order => "created_on ASC"
  has_many :links
  has_many :songs
  file_column :logo, :magick => { :geometry => "240x320>" }
  has_one :upload_addr
  acts_as_searchable
  
  
  validates_uniqueness_of :uuid # just in case
  validates_presence_of :name
  validate_not_reserved :short_name, :words => ActionController::Routing::Routes.known_controllers, 
                        :message => "Sorry, you have chosen a reserved name. Choose a new public page name."
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
  
  def play_show(show, order = 0, extra_info = nil)
    show.bands.push_with_attributes(self, :set_order => order, :extra_info => extra_info)
    self.num_upcoming_shows = self.upcoming_shows(true).size
  end

  def validate_unique_email?
    super and self.claimed?
  end
  
  def location
    return self.city + ", " + self.state unless self.city.nil? or self.city == ""
    return ""
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
    id = name.gsub(/&/, 'and').gsub(/[^\w|\d|_|.|-]/, '').downcase
  end
  
  # Add Band tags
  def band_tag_names=(tags)
    add_tags(tags, Tag.Band)
  end

  # Get just the Band tags
  def band_tag_names
    get_tags(Tag.Band)
  end
  
  def add_related_band(other)
    Band.transaction do
      self.related_bands << other
      other.related_bands << self
    end
  end
  
  # For admin use
  def incorporate_dupe(other)
    # Transfer fans
    other.fans.each do |fan|
      fan.add_favorite(self, FavoriteBandEvent::SOURCE_DUPE)
      fan.remove_favorite(other, FavoriteBandEvent::SOURCE_DUPE)
      fan.save!
    end
    
    # Transfer shows
    other.shows.each do |show|
      other_set = show.bands.find(other.id)
      set_order = other_set.nil? ? show.bands.size - 1 : other_set.set_order
      show.remove_band(other)
      self.play_show(show, set_order)
    end
       
    Band.destroy(other.id)
    self.save!
  end
  
  # The upload email address, fully qualified like "down42tree@tourb.us"
  def upload_email_addr()
    return upload_addr.address + "@" + UploadAddr.Domain
  end
  
  # Find bands created since the given date
  def self.find_created_since(date)
    self.find(:all, :conditions => ['created_on > ?', date])
  end
  
  # The popularity is currently a somewhat arbitrary number.
  def popularity
    self.num_fans
  end
  
  def related?(other)
    self.related_bands.include?(other)
  end
  
  def add_related_band(other)
    return if self.related?(other)
    
    BandRelation.transaction do
      BandRelation.new(:band1 => self, :band2 => other).save!
      BandRelation.new(:band2 => self, :band1 => other).save!
      
      # NOTE: With has_many :through relations, adding the relation directly like we 
      # do here does not automatically add the related item, so we have to re-fetch
      # the related bands
      self.related_bands(true)
      other.related_bands(true)
    end
  end
  
  # Create a new unclaimed band
  def self.new_band(name)
    band = Band.new
    band.claimed = false
    band.name = name
    band.short_name = Band.name_to_id(name)
    band.uuid = UUID.random_create.to_s
    band
  end
  
  def self.index_all
    super(:include => :tags)
  end
  
  protected
  
  # Index band-specific fields
  def add_searchable_fields(xml)
    if !self.latitude.blank?
      xml.field(self.latitude, :name => "latitude")
      xml.field(self.longitude, :name => "longitude")
    end
  end
end
