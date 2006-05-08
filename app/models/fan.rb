# Schema as of Thu Mar 02 20:14:39 Eastern Standard Time 2006 (schema version 17)
#
#  id                  :integer(11)   not null
#  name                :string(100)   default(), not null
#  real_name           :string(100)   default(), not null
#  contact_email       :string(100)   default(), not null
#  zipcode             :string(5)     
#  city                :string(100)   default()
#  state               :string(2)     default()
#  bio                 :text          
#  salt                :string(40)    
#  website             :string(100)   default()
#  salted_password     :string(40)    default(), not null
#  logo                :string(100)   default(), not null
#  confirmed           :boolean(1)    not null
#  confirmation_code   :string(50)    default()
#  created_on          :datetime      
#  page_views          :integer(10)   default(0)
#  last_favorites_email:datetime      
#  default_radius      :integer(6)    default(35)
#  wants_favorites_emai:boolean(1)    default(true), not null
#  admin               :boolean(1)    not null
#  security_token      :string(40)    
#  token_expiry        :datetime      
#  show_reminder_first :integer(10)   default(4320)
#  show_reminder_second:integer(10)   default(360)
#  wants_email_reminder:boolean(1)    default(true)
#  wants_mobile_reminde:boolean(1)    
#  last_show_reminder  :datetime      
#  uuid                :string(40)    
#  last_updated        :datetime      
#  superuser           :boolean(1)    
#  mobile_number       :string(20)    
#  carrier_type        :integer(10)   default(-1)
#  show_watching_remind:integer(10)   default(4320)
#  longitude           :string(30)    
#  latitude            :string(30)    
#

require_dependency "password_protected"
require_dependency "searchable"
require_dependency "address"
require_dependency "mobile_address"

# Model that describes a music fan
class Fan < ActiveRecord::Base
  include ActiveRecord::Acts::PasswordProtected
  include FerretMixin::Acts::Searchable
  include Address::ActsAsLocation
  include MobileAddress
  include UpcomingShows
  
  acts_as_password_protected
  file_column :logo, :magick => { :geometry => "200x300>" }
  has_many :photos, :class_name => "Photo", :foreign_key => "created_by_fan_id", :order => "created_on DESC"
  has_one :upload_addr, :dependent => true
  has_and_belongs_to_many :bands
  has_and_belongs_to_many :shows, :order => "date ASC", :include => [:venue, :bands]
  has_many :comments, :order => "created_on ASC"
  has_many :wish_list_bands, :dependent => true, :order => "name ASC"
 
  validates_uniqueness_of :uuid # just in case
  
  validates_presence_of :name, :contact_email
  validates_numericality_of :default_radius, :allow_nil => true, :if => Proc.new { |fan| fan.default_radius != '' }
  validates_uniqueness_of :name, 
                          :message => "Sorry, that name has already been taken."
  
  validates_uniqueness_of :contact_email, 
                          :message => "Sorry, someone has already signed up with that email address.",
                          :if => :validate_unique_email?
  
                          
  validates_presence_of :password, :if => :validate_password?
  validates_length_of :password, :minimum => 4, :if => :validate_password?
  validates_confirmation_of :password, :if => :validate_password?
  
  def validate
    if self.name =~ /[^\w|\d]/
      errors.add_to_base("Sorry, your username can only contain letters and numbers")
    end
  end
  
  # Returns the admin user
  def self.admin
    self.find_by_name('admin')
  end
  
  # Return's Gary's user
  def self.gary
    self.find_by_name('gary')
  end
  
  # Returns Mike's user
  def self.mike
    self.find_by_name('mike') 
  end
  
  # Mike's secret identity for fighting crime
  def self.bushido
    self.find_by_name('bushido') 
  end
  
  # Return if the band is among the fan's favorites
  def favorite?(band)
    self.bands.detect { |fav| fav == band }
  end
  
  def add_favorite(band)
    return if self.favorite?(band)
    
    self.bands << band
    band.num_fans += 1
  end
  
  def remove_favorite(band)
    self.bands.delete(band)
    band.num_fans -= 1
  end 
  
  def attend_show(show)
    return if self.attending?(show)
    
    self.stop_watching_show(show)
    self.shows.push_with_attributes(show, { :attending => true, :watching => false })
    show.num_attendees += 1
  end
  
  def wishlist?(band)
    self.wish_list_bands.detect { |ws_band| ws_band.short_name == Band.name_to_id(band) }
  end
  
  def add_wish_list_bands(*bands)
    bands.each { |band| self.wish_list_bands << WishListBand.new(:name => band) if !self.wishlist?(band) }
  end
  
  def find_wish_list_band(name)
    self.wish_list_bands.find_by_name(name) || self.wish_list_bands.find_by_short_name(Band.name_to_id(name))
  end
  
  def stop_attending_show(show)
    if self.attending?(show)
      self.shows.delete(show)
      show.num_attendees -= 1
    end
  end
  
  def watch_show(show)
    return if self.watching?(show)
    
    self.stop_attending_show(show)
    self.shows.push_with_attributes(show, { :attending => false, :watching => true })
    show.num_watchers += 1
  end
  
  def stop_watching_show(show)
    if self.watching?(show)
      self.shows.delete(show)
      show.num_watchers -= 1
    end
  end
  
  # Watch all upcoming shows for the given band in the fan's area
  def watch_upcoming(bands)
    a = [self.latitude, self.longitude, self.default_radius]
    return if a.include?(nil) or a.include?('')
    
    bands.each do |band|
      shows = band.upcoming_shows
      
      if shows.size > 0
        # Reselect so the records aren't R/O                        
        # TODO Factor this out
        sql = 'id in (' + shows.map { |show| show.id }.join(',') + ')'
        shows = Show.find(:all, :conditions => sql)
      end
      
      shows.each do |show|
        if Address::within_range?(show.venue.latitude, show.venue.longitude, self.latitude, self.longitude, self.default_radius)
          self.watch_show(show)
          show.save!
        end
      end
    end
  end
  
  def watching_shows
    self.shows.find(:all, :conditions => "watching = 1")
  end
  
  def attending_shows
    self.shows.find(:all, :conditions => "attending = 1")
  end
  
  # Return if the show is one the fan is attending
  def attending?(show)
    self.attending_shows.include?(show)
  end
  
  # Return if the show is one the fan is watching
  def watching?(show)
    self.watching_shows.include?(show)
  end
  
  def attending_or_watching?(show)
    self.watching?(show) or self.attending?(show)
  end
                          
  # Creates and sets the confirmation code. DOES NOT save the record.
  # Requires that that object already be populated with required fields
  def create_confirmation_code
    self.confirmation_code = Hash.hashed(self.name + rand.to_s)
    return self.confirmation_code
  end
  
  # The upload email address, fully qualified like "down42tree@tourb.us"
  def upload_email_addr()
    return upload_addr.address + "@" + UploadAddr.Domain
  end
  
  def location
    return self.city + ", " + self.state unless self.city.nil? or self.city == ""
    return ""
  end
  
  # Returns the band if it was authenticated.
  # May return an unconfirmed band, the caller must check.
  def self.authenticate(login, password)
    fan = find_by_name(login)
    return nil if fan.nil?
    return find(:first, 
                :conditions => ["confirmed = 1 and name = ? and salted_password = ?", login, Fan.salted_password(fan.salt, Hash.hashed(password))])
  end
  
  # Get the mobile email address for this fan
  def mobile_email

    return MobileAddress::get_mobile_email(mobile_number, carrier_type)
  end  
  
  # Returns an array of reminder options in minutes
  def self.reminder_options
    
    ops = [
            ["---", 0], ["1 hour", 60], 
            ["2 hours", 120], ["3 hours", 180], ["6 hours", 360], ["12 hours", 720],
            ["1 day", 1440], ["2 days", 2880], ["3 days", 4320], ["5 days", 7200],
            ["7 days", 10080], ["10 days", 14400], ["14 days", 20160]
          ]
  end

end
