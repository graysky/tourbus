require 'RMagick'

class Photo < ActiveRecord::Base
  belongs_to :show
  belongs_to :band
  belongs_to :venue
  has_many :comments, :order => "created_at ASC"
  belongs_to :created_by_band, :class_name => "Band", :foreign_key => "created_by_band_id"
  belongs_to :created_by_fan, :class_name => "Fan", :foreign_key => "created_by_fan_id"
  
  BAND_TYPE = "band"
  SHOW_TYPE = "show"
  VENUE_TYPE = "venue"
  FROM_FAN = "from_fan"
  FROM_BAND = "from_band"
  
  def self.Band
    BAND_TYPE
  end
  
  def self.Show
    SHOW_TYPE
  end
  
  def self.Venue
    VENUE_TYPE
  end
  
  def self.FromFan
    FROM_FAN
  end
  
  def self.FromBand
    FROM_BAND
  end
  
  VERSIONS = [{ :name => "thumbnail", :size => "70x70>" },
              { :name => "preview", :size => "120x120>" },
              { :name => "normal", :size => "575x575>" }].freeze
              
  
  def file=(file)
    self.filename = sanitize_filename(file.original_filename)
    @file = file
  end
 
  def relative_path(version_name = nil)
    return "/" + path_to_version_file(version_name, false)
  end
 
  def before_save
    return if not @file
    
    # Make the filename unique
    i = 1
    name = self.filename.to_s
    while File.exists?(path_to_file)
      self.filename = (i += 1).to_s + "-" + name
    end
    
    if @file.respond_to?(:local_path) and @file.local_path and File.exists?(@file.local_path)
      # Copy the file to the correct location
      FileUtils.copy_file(@file.local_path, path_to_file)
    elsif @file.respond_to?(:read)
      # Read it out of memory and write to the location
      File.open(self.path_to_file, "wb") { |f| f.write(@file.read) }
    else
      raise ArgumentError.new("Do not know how to handle #{@file.inspect}")
    end
    
    make_versions
  end
 
  def created_by_name
    creator.name
  end
 
  # Returns the subject of the photo (the band, show, venue, etc)
  def subject
    self.band or self.venue or self.show
  end
 
  def creator
    self.created_by_fan or self.created_by_band
  end
 
  def before_destroy
    File.delete(path_to_file)
    
    VERSIONS.each do |version|
      File.delete(path_to_version_file(version[:name]))
    end
  end
  
   # Get file location
  def path_to_file(file = self.filename, include_base = true)
    # Use a different directory depending on what type of object the photo belongs to
    base = include_base ? "#{RAILS_ROOT}/public/" : ""
    if not self.band.nil?
      type = "band"
    elsif not self.show.nil?
      type = "show"
    elsif not self.venue.nil?
      type = "venue"
    else
      raise ArgumentError.new("No suitable type for the photo")
    end
 
    base + type + "/" + file
  end
  
  # Private
  private
  
  def make_versions
    orig = ::Magick::Image.read(path_to_file).first
    VERSIONS.each do |version|
      image = orig.change_geometry(version[:size]) do |cols, rows, img|
        img.resize(cols, rows)
      end
      
      image.write(path_to_version_file(version[:name]))
    end
  end
  
  def path_to_version_file(name, include_base = true)
    filename = name ? name + "-" + self.filename : self.filename
    path_to_file(filename, include_base)
  end
  
  def sanitize_filename(name)
    # get only the filename, not the whole path and
    # replace all none alphanumeric, underscore or periods with underscore
    File.basename(name.gsub('\\', '/')).gsub(/[^\w\.\-]/,'_') 
  end
  
end
