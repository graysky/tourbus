require_dependency "taggable"
require_dependency "tagging"
require_dependency "searchable"

# Describes a venue where shows are played
class Venue < ActiveRecord::Base
  include FerretMixin::Acts::Searchable
  include Tagging
  
  has_many :shows, :order => "date ASC"
  has_many :photos, :order => "created_on DESC"
  has_many :comments, :order => "created_on ASC"
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
  def add_searchable_fields
    # We need to index our location
    fields = []
    fields << Document::Field.new("latitude", self.latitude, Document::Field::Store::YES, Ferret::Document::Field::Index::UNTOKENIZED)
    fields << Document::Field.new("longitude", self.longitude, Document::Field::Store::YES, Ferret::Document::Field::Index::UNTOKENIZED)
    return fields
  end
  
end
