# Schema as of Sun Feb 18 18:07:46 Eastern Standard Time 2007 (schema version 43)
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
#  preamble            :string(255)   
#  site_visit_id       :integer(11)   
#  source_link         :string(255)   
#  source_name         :string(255)   
#  edited_by_fan_id    :integer(11)   
#  edited_by_band_id   :integer(11)   
#

require_dependency "searchable"
require_dependency "taggable"
require_dependency "tagging"

# A specific show that is being played a venue by a list of bands.
class Show < ActiveRecord::Base
  include FerretMixin::Acts::Searchable
  
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
  belongs_to :edited_by_band, :class_name => "Band", :foreign_key => "edited_by_band_id"
  belongs_to :edited_by_fan, :class_name => "Fan", :foreign_key => "edited_by_fan_id"
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
  
  # Fans with the given fans friends first
  def fans_friends_first(fan, random = false)
    fans = random ? self.fans.random : self.fans
    fans.sort do |x, y|
      if fan.friends_with?(x)
        -1  
      elsif fan.friends_with?(y)
        1
      else 
        0
      end
    end
  end
  
  # Return the subset of shows that are within the given range
  def self.within_range(shows, lat, long, radius)
    shows = shows.find_all do |show|
      next unless !show.nil? && show.kind_of?(Show)
      Address::within_range?(show.venue.latitude.to_f, show.venue.longitude.to_f, 
                             lat.to_f, long.to_f, radius.to_f)
    end
  end
 
  def remove_band(band)
    self.bands.delete(band)
  end
   
  # Returns a list of shows that are probably identical to the given show,
  # or nil if there are none
  def self.find_probable_dups(other)
    # A bit of a hack here. We need to force the show to update its date attribute
    other.before_validation
    Show.find_by_venue_id_and_date(other.venue.id, other.date)
  end
  
  def num_all_attendees
    self.num_watchers + self.num_attendees
  end
  
  # The popularity is currently a somewhat arbitrary number.
  def popularity
    # The popularity of a show is determined by the number of watchers and attendees
    # An attendee is worth twice as much as a watcher.
    self.num_watchers + (2 * self.num_attendees)
  end
  
  def self.index_all
    super(:include => [:tags, :bands, :venue])
  end
  
  protected
  
  # Add show-specific searchable fields for ferret indexing
  def add_searchable_fields(xml)
    if !self.venue.latitude.blank?
      xml.field(self.venue.latitude, :name => "latitude")
      xml.field(self.venue.longitude, :name => "longitude")
      xml.field(self.num_watchers, :name => "num_watchers")
      xml.field(self.num_attendees, :name => "num_attendees")
      xml.field(Show.indexable_date(self.date), :name => "date")
    end
  end
  
  # Add show-specific searchable contents for ferret indexing
  def add_searchable_contents
    contents = ""
    self.bands.each do |band| 
      contents << " " + band.name
      contents << " " + band.tag_names.join(" ")
    end
   
    contents << " " + self.venue.name + " " + self.venue.city
    contents << self.description
    
    contents
  end
  
end
