require 'monitor'

class SongSite < ActiveRecord::Base
  @@lock = Monitor.new
  
  has_many :songs
  validates_uniqueness_of :url
  
  CRAWL_INTERVAL = 14.days
  
  # If there was an error last time, crawl again sooner
  CRAWL_ERROR_INTERVAL = 1.days
  
  # Disable a site after three consecutive errors
  CRAWL_ERROR_THRESHOLD = 3
  
  CRAWL_STATUS_DISABLED = -1
  CRAWL_STATUS_INACTIVE = 0
  CRAWL_STATUS_ACTIVE = 1
  
  MAX_CRAWL_TIME = 12.hours
  
  EXCLUSIONS = %w[ myspace purevolume.com wikipedia google.com allmusic.com amazon.co 
                   garageband.com ticketmaster.com phobos.apple.com mp3.com imdb.com last.fm
                   blog pandora.com yahoo.com microsoft.com pitchforkmedia.com ]
  
  # Make sure we don't save sites we don't want to crawl
  def before_save
    super
    
    for e in EXCLUSIONS
      raise "Not allowed to crawl #{self.url}" if self.url.index(e)
    end
  end
  
  # Provide thread-safe access to the next url to crawl
  def self.next_crawlable_site(worker)
    @@lock.synchronize do
      conditions = ["crawl_status = ? and (crawled_at is null or crawled_at < ? or (crawl_error = ? and crawled_at < ?))", 
                    CRAWL_STATUS_INACTIVE, Time.now - CRAWL_INTERVAL, true, Time.now - CRAWL_ERROR_INTERVAL]
      site = SongSite.find(:first, :conditions => conditions, :order => "crawled_at asc")
      
      if site
        site.assign(worker)
      end
      
      site
    end
  end
  
  def finish_crawl(worker, error, comment, count)
    raise "#{worker} did not initiate crawl" if self.crawl_worker != worker
    raise "Crawl not in progress for site #{self.id}" if self.crawl_status != CRAWL_STATUS_ACTIVE
    
    self.crawled_at = Time.now()
    self.assigned_at = nil
    self.crawl_worker = nil
    self.crawl_status = CRAWL_STATUS_INACTIVE
    self.last_crawl_comment = comment
    self.crawl_error = error
    self.crawled_songs = count
   
    if self.crawl_error
      self.crawl_error_count += 1
    else
      self.crawl_error_count = 0
    end
   
    self.crawl_status = CRAWL_STATUS_DISABLED if self.crawl_error_count >= CRAWL_ERROR_THRESHOLD
    
    self.save!
  end
  
  def renew(worker)
    if !(self.crawl_status == CRAWL_STATUS_ACTIVE && self.worker != worker)
      self.assign(worker)
      return true
    end
    
    return false
  end
  
  def self.cleanup_old_crawls
    conditions = ["crawl_status = ? and assigned_at < ?", CRAWL_STATUS_ACTIVE, Time.now - MAX_CRAWL_TIME]
    sites = self.find(:all, :conditions => conditions)
    
    for site in sites
      site.assigned_at = nil
      site.crawl_status = CRAWL_STATUS_INACTIVE
      site.last_crawl_comment = "Cleaned up at #{Time.now}"
      site.crawl_error = true
      site.crawl_error_count += 1  
      site.crawl_status = CRAWL_STATUS_DISABLED if site.crawl_error_count >= CRAWL_ERROR_THRESHOLD
      site.save!
    end
  end
  
  def assign(worker)
    self.crawl_worker = worker
    self.crawl_status = CRAWL_STATUS_ACTIVE
    self.assigned_at = Time.now
    self.crawl_error = false
    self.crawled_songs = 0
    self.save!
  end
  
end