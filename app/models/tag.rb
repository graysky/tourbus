# A tag that is applied to a band.
class Tag < ActiveRecord::Base
  has_and_belongs_to_many :bands

  validates_presence_of :name
  validates_uniqueness_of :name

  # Types of tags
  GENRE_TYPE = 0
  INFLUENCE_TYPE = 1
  MISC_TYPE = 2
  VENUE_TYPE = 3
  
  # Getter for type
  def self.Genre
    GENRE_TYPE
  end
  
  def self.Influence
    INFLUENCE_TYPE
  end
  
  def self.Misc
    MISC_TYPE
  end
  
  def self.Venue
    VENUE_TYPE
  end
  
  # Get a string name for the tag type
  def self.type_name(tag_type)
    case tag_type
      when GENRE_TYPE
        "Genre"
      when INFLUENCE_TYPE
        "Influence"
      when MISC_TYPE
        "Other"
      when VENUE_TYPE
        "Venue"
      else
        "Error"
    end
  end

end
