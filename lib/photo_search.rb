require 'flickr'

FLICKR_API_KEY = 'c3a627d98da4cbb53042955c55702bc7'

class Flickr
  alias :orig_initialize :initialize
  
  @last_request = nil
  
  def initialize(api_key = FLICKR_API_KEY, email=nil, password=nil)
    @api_key = api_key
    @host = 'http://flickr.com'
    @api = '/services/rest'
    login(email, password) if email and password
  end
  
  # Implements flickr.photos.getRecent and flickr.photos.search
  def photos(*criteria)
    photos = (criteria[0]) ? photos_search(criteria[0]) : photos_getRecent
    return [] unless photos && photos['photos']['photo']
    
    if photos['photos']['photo'].is_a?(Hash)
      return [Photo.new(photos['photos']['photo']['id'])]
    end
    
    photos['photos']['photo'].collect do |photo|
      Photo.new(photo['id'])
    end
  end
  
  class Photo
    attr_accessor :date_taken
  
    def getInfo
      info = @client.photos_getInfo('photo_id'=>@id)['photo']
      @title = info['title']
      @owner = User.new(info['owner']['nsid'])
      @server = info['server']
      @isfavorite = info['isfavorite']
      @license = info['license']
      @rotation = info['rotation']
      @description = info['description']
      @notes = info['notes']['note']#.collect { |note| Note.new(note.id) }
      
      date = info['dates']['taken']
      if date
        @date_taken = Time.parse(date)
      end
      
      self
    end
    
    def photopage_url
      self.owner.url.gsub(/\/people/, "/photos") + "#{@id}"
    end
    
    def date_taken
      @date_taken.nil? ? getInfo.date_taken : @date_taken
    end
    
    def sizes
      unless @sizes
        @sizes = @client.photos_getSizes('photo_id'=>@id)['sizes']['size']
      end
      
      return @sizes
    end
    
    def size(s)
      sizes.find{ |asize| asize['label'] == s }
    end
    
    def thumbnail
      size('Thumbnail')['source'] if size('Thumbnail')
    end
    
    def medium
      size('Medium')['source'] if size('Medium')
    end
    
    def small
      size('Small')['source'] if size('Small')
    end
    
    def square
      size('Square')['source'] if size('Square')
    end
  end
  
end

class PhotoSearch
  
  PER_PAGE = 200
  MIN_SHOW_PHOTOS = 20
  FLICKR_TIME_FORMAT = "%Y-%m-%d %H:%M:%S"
  
  attr_reader :flickr
  
  def initialize
    @flickr = Flickr.new
  end
  
  def flickr_time(time)
    time.strftime(FLICKR_TIME_FORMAT)
  end
  
  def find_show_photos(band, oldest_show = 3.months.ago)
    # Search for photos we think were taken at past shows of this band
    shows = band.shows.find(:all, :conditions => ["date >= ?", oldest_show])
    for show in shows
      date = show.date
      if date.hour == 0
        date = date + 19.hours
      end
      
      puts "#{band.name} - #{date}"
      
      min_date = date - 8.hours
      max_date = date + 12.hours
      
      name_tag = band.short_name
      tags = "#{name_tag}, concert"
      
      photos = do_with_retry do
        @flickr.photos(:tags => tags, :per_page => PER_PAGE.to_s, :tag_mode => 'all', 
                       :min_taken_date => flickr_time(min_date), :max_taken_date => flickr_time(max_date))
      end
      
      puts "  found #{photos.size} photos"
      if photos.size < MIN_SHOW_PHOTOS
        tags = "#{name_tag}, livemusic"
        
        photos += do_with_retry do
          @flickr.photos(:tags => tags, :per_page => PER_PAGE.to_s, :tag_mode => 'all', 
                         :min_taken_date => flickr_time(min_date), :max_taken_date => flickr_time(max_date))
        end
        
        puts "  look for livemusic, now found #{photos.size} photos"
      end
      
      if photos.size < MIN_SHOW_PHOTOS && name_tag.starts_with?("the")
        name_tag = name_tag[3..-1]
        tags = "#{name_tag}, concert"
        photos += do_with_retry do
          @flickr.photos(:tags => tags, :per_page => PER_PAGE.to_s, :tag_mode => 'all', 
                         :min_taken_date => flickr_time(min_date), :max_taken_date => flickr_time(max_date))
        end
        
        puts "  look without 'the', now found #{photos.size} photos"
      end
      
      for photo in photos[0..20]
        next if FlickrPhoto.find_by_flickr_id(photo.id)
        
        next unless photo.thumbnail && photo.medium && photo.square && photo.small
        fp = do_with_retry do
          FlickrPhoto.new(:band_id => band.id, :show_id => show.id, :photopage_url => photo.photopage_url,
                           :thumbnail_source => photo.thumbnail, :medium_source => photo.medium, :square_source => photo.square,
                           :title => photo.title, :owner => photo.owner.id, :flickr_id => photo.id,
                           :date => photo.date_taken, :venue_id => show.venue.id, :small_source => photo.small)
         end
         
        fp.save!
      end
    end
    
    if band.flickr_photos.size < 20
      # Look for other photos to fill things out
      puts "   Try to find unattached photos"
      
      tags = "#{band.short_name}, concert"
      photos = do_with_retry do
        @flickr.photos(:tags => tags, :per_page => "200", :tag_mode => 'all', 
                       :min_taken_date => flickr_time(6.months.ago))
      end
      
      photos = photos.random(40)
      puts "    Add #{photos.size} unattached photos"
      for photo in photos
        next unless photo.thumbnail && photo.medium && photo.square && photo.small
        fp = do_with_retry do
          FlickrPhoto.new(:band_id => band.id, :photopage_url => photo.photopage_url,
                           :thumbnail_source => photo.thumbnail, :medium_source => photo.medium, :square_source => photo.square,
                           :title => photo.title, :owner => photo.owner.id, :flickr_id => photo.id,
                           :date => photo.date_taken, :small_source => photo.small)
        end
        
        fp.save!
      end
    end
    
    return nil
  end
  
  def do_with_retry(retries = 3)
    ret = nil
    sleep_time = 1
    begin
      sleep(sleep_time)
      ret = yield
    rescue Exception => e
      puts "Error talking to flickr: #{e}, #{e.backtrace}"
      if retries > 0
        puts "Retrying..."
        retries -= 1
        sleep_time *= 2
        retry
      end
    end
    
    raise "Too many errors" unless ret
    return ret
  end
  
end