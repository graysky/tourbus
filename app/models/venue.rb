# Schema as of Sun Feb 18 18:07:46 Eastern Standard Time 2007 (schema version 43)
#
#  id                  :integer(11)   not null
#  name                :string(100)   default(), not null
#  url                 :string(100)   default(), not null
#  address             :string(255)   default(), not null
#  city                :string(100)   default(), not null
#  state               :string(2)     default(), not null
#  zipcode             :string(10)    default(), not null
#  country             :string(45)    default(), not null
#  phone_number        :string(15)    default(), not null
#  description         :text          default(), not null
#  contact_email       :string(100)   default(), not null
#  latitude            :string(30)    
#  longitude           :string(30)    
#  page_views          :integer(10)   default(0)
#  last_updated        :datetime      
#  short_name          :string(255)   
#  num_upcoming_shows  :integer(11)   default(0)
#

require_dependency "taggable"
require_dependency "tagging"
require_dependency "searchable"

# Describes a venue where shows are played
class Venue < ActiveRecord::Base
  include FerretMixin::Acts::Searchable
  include Address::ActsAsLocation
  include Tagging
  
  has_many :shows, :order => "date ASC" #,  :include => [:bands]
  has_many :upcoming_shows, :class_name => 'Show', :conditions => ["date > ?", Time.now], :order => "date ASC"
  has_many :photos, :order => "created_on DESC"
  has_many :comments, :order => "created_on ASC"
  has_many :flickr_photos, :order => "date DESC"
  acts_as_taggable :join_class_name => 'TagVenue'
  acts_as_searchable
  
  validates_presence_of :name
  
  # Set the url field, making sure it is properly qualified
  def url=(url)

    # Validate before saving
    valid_url = validate_url(url)

    write_attribute("url", valid_url)
  end

  # Add Venue tags
  def venue_tag_names=(tags)
    add_tags(tags, Tag.Venue)
  end

  # Get just the Venue tags
  def venue_tag_names
    get_tags(Tag.Venue)
  end
  
  def all_photos
    self.photos + self.flickr_photos
  end
  
  def location
    return self.city + ", " + self.state unless self.city.nil? or self.city == ""
    return ""
  end
  
  def address_one_line
    self.address + "," + self.city_state_zip
  end
  
  def set_location_from_hash(result)
    self.latitude = result[:latitude]
    self.longitude = result[:longitude]
    self.city = result[:city].titlecase
    self.address = result[:address]
    self.state = result[:state]
    self.zipcode = result[:zipcode]
  end
  
  def popularity
    return self.num_upcoming_shows
  end
  
  # All recent and upcoming shows at the venue
  def recent_upcoming_shows
    self.shows.find(:all, :conditions => ["date > ?", Time.now - 2.months], :include => :bands)
  end
  
  # The short name is name with whitespace and punctuation stripped out, all lowercase
  def self.name_to_short_name(name)
    # Remove anything that's not a letter, number or selected punctuation
    name.gsub(/[^\w|\d]/, '').downcase
  end
  
  def self.index_all
    super(:include => [:upcoming_shows])
  end
  
  # Change default for SEO friendlyness. Format is:
  # id-name-city-state
  def to_param
    url = "#{id}-#{StringHelper::urlize(name)}"
    
    # Not all venues have states (like D.C.)
    url = url + "-#{StringHelper::urlize(city)}" if !city.nil?
    url = url + "-#{StringHelper::urlize(state)}" if !state.nil?
   
    return url    
  end
  
  protected
  
  # Validate that it is a valid URL starting with http://
  # return a validated form of it. If the url is nil, nil is returned
  def validate_url(url)
    
    # Prepend right start if it is missing.    
    if (url != nil) && !url.match(/^http/i)
      url.insert(0, 'http://')
    end
  
    return url
  end
  
  # Add venue-specific searchable fields for ferret indexing
  def add_searchable_fields(xml)
    xml.field(self.latitude, :name => "latitude")
    xml.field(self.longitude, :name => "longitude")
  end
  
  # Add venue-specific searchable contents for ferret indexing
  def add_searchable_contents
    contents = ""
    self.recent_upcoming_shows.each do |show|
      show.bands.each do |band| 
        contents << " " + band.name
        contents << " " + band.tags.join(" ")
      end
    end
    
    contents << " " + self.city
    
    contents
  end
  
end
