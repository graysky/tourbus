# Schema as of Thu Mar 02 20:14:39 Eastern Standard Time 2006 (schema version 17)
#
#  id                  :integer(11)   not null
#  cost                :string(50)    
#  title               :string(100)   
#  bands_playing_title :string(200)   
#  description         :text          default(), not null
#  url                 :string(100)   default(), not null
#  date                :datetime      not null
#  page_views          :integer(10)   default(0)
#  venue_id            :integer(10)   default(0), not null
#  created_by_fan_id   :integer(10)   
#  created_by_band_id  :integer(10)   
#  created_by_system   :boolean(1)    not null
#  created_on          :datetime      
#  last_updated        :datetime      
#  num_attendees       :integer(11)   default(0)
#  num_watchers        :integer(11)   default(0)
#

require_dependency "searchable"
require_dependency "taggable"
require_dependency "tagging"
require 'ferret'

# A specific show that is being played a venue by a list of bands.
class Show < ActiveRecord::Base
  include FerretMixin::Acts::Searchable
  include Ferret
  
  include Tagging
  has_and_belongs_to_many :bands, :order => "bands_shows.set_order"
  has_and_belongs_to_many :fans
  belongs_to :venue
  belongs_to :site_visit
  acts_as_searchable
 
  has_many :photos, :order => "created_on DESC"
  has_many :comments, :order => "created_on ASC"
  belongs_to :created_by_band, :class_name => "Band", :foreign_key => "created_by_band_id"
  belongs_to :created_by_fan, :class_name => "Fan", :foreign_key => "created_by_fan_id"
  acts_as_taggable :join_class_name => 'TagShow'
  validates_presence_of :date
  
  # Attributes for nicer date handling
  attr_accessor :formatted_date, :time_hour, :time_minute, :time_ampm
  
  # ActiveRecord callback:
  # Convert our formatted date attributes into the real date 
  def before_validation
    # Create a string that ParseDate can handle
    date_str = "#{@formatted_date} #{@time_hour}:#{@time_minute}#{@time_ampm}"
    components = ParseDate.parsedate(date_str)
    return if components[0].nil?
    
    self.date = Time.local(*components)
  end
  
  # Get the show's title formatted as either:
  # 1) title (if provided)
  # 2) band1/band2/band3
  # TODO Optimize this by saving this string to the db when the show is saved
  def formatted_title
    if !self.title.nil? and self.title != ""
      return self.title
    else
      # Format the list of bands to be the title
      self.bands.map { |band| band.name }.join("/")
    end
  end
  
  # Alias name to title to make Show more uniform with other objs
  def name
    formatted_title
  end
  
  def formatted_date
    return @formatted_date if self.date.nil?
    
    month = Date::MONTHNAMES[self.date.month] 
    "#{month} #{self.date.day}, #{self.date.year}"
  end
  
  def time_hour
    return @time_hour if self.date.nil?
    ampm = time_ampm
    if (ampm == "PM")
      return self.date.hour - 12
    elsif (self.date.hour == 0)
      return 12
    else
      return self.date.hour
    end  
  end
  
  def time_minute
    return @time_minute if self.date.nil?
    self.date.min
  end
  
  def time_ampm
    return @time_ampm if self.date.nil?
    if (self.date.hour > 12)
      return "PM"
    else
      return "AM"
    end
  end
  
  def from_site
    self.site_visit
  end
  
  # Add Show tags
  def show_tag_names=(tags)
    add_tags(tags, Tag.Show)
  end

  # Get just the Show tags
  def show_tag_names
    get_tags(Tag.Show)
  end
  
  def fans_attending_first
    self.fans.find(:all, :order => "attending DESC")
  end
  
  # Returns a list of shows that are probably identical to the given show,
  # or nil if there are none
  def self.find_probable_dups(other)
    # A bit of a hack here. We need to force the show to update its date attribute
    other.before_validation
    Show.find_by_venue_id_and_date(other.venue.id, other.date)
  end
  
  # The popularity is currently a somewhat arbitrary number.
  def popularity
    # The popularity of a show is determined by the number of watchers and attendees,
    # as well as the popularity of all bands playing the show.
    # An attendee is worth twice as much as a watcher.
    popularity = self.num_watchers + (2 * self.num_attendees)
    
    fans = self.bands.inject(0) { |sum, band| sum + band.num_fans }
    
    # For now, increase popularity by the percentage of all fans that are
    # fans of a band playing the show.
    popularity + ((fans.to_f / Fan.count.to_f) * 100).to_i
  end
  
  protected
  
  # Add show-specific searchable fields for ferret indexing
  def add_searchable_fields
    fields = []
   
    fields << Document::Field.new("latitude", self.venue.latitude, Document::Field::Store::YES, Ferret::Document::Field::Index::UNTOKENIZED)
    fields << Document::Field.new("longitude", self.venue.longitude, Document::Field::Store::YES, Ferret::Document::Field::Index::UNTOKENIZED)
    fields << Document::Field.new("num_watchers", self.num_watchers, Document::Field::Store::YES, Ferret::Document::Field::Index::UNTOKENIZED)
    fields << Document::Field.new("num_attendees", self.num_attendees, Document::Field::Store::YES, Ferret::Document::Field::Index::UNTOKENIZED)
    
    # We need to be able to search by the date of the show
    fields << Document::Field.new("date", Show.indexable_date(self.date), Document::Field::Store::YES, Ferret::Document::Field::Index::UNTOKENIZED)
    return fields
  end
  
  # Add show-specific searchable contents for ferret indexing
  def add_searchable_contents
    contents = ""
    self.bands.each do |band| 
      contents << " " + band.name
      contents << " " + band.tag_names.join(" ")
    end
   
    contents << " " + self.venue.name + " " + self.venue.city
    
    contents
  end
  
end
