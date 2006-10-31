require 'webrick'
require 'config/environment'
require 'request_servlets'

# Song crawler service... depends on ruby on rails and the tourbus project
class SongCrawlerService
  
  # Start the SongCrawlerService
  def start(port = 9863)
    # Set up logging
    logger = WEBrick::Log.new("#{RAILS_ROOT}/log/song_crawler_service.log")
    
    config = { :Port => port, :Logger => logger }
    @server = WEBrick::HTTPServer.new(config)
    
    # Trap signals
    ['INT', 'TERM'].each do |signal| 
      trap(signal) { @server.shutdown }
    end
    
    # Mount our servlets
    @server.mount("/get_work", GetWorkServlet)
    @server.mount("/finish_crawl", FinishCrawlServlet)
    @server.mount("/add_songs", AddSongsServlet)
    @server.mount("/renew_work", RenewWorkServlet)
    
    # Start a background thread to clean up old crawls
    Thread.start do
      while true
        logger.info("Cleaning up old crawls")
        SongSite.cleanup_old_crawls
        sleep 15.minutes
      end
    end
    
    # AR has strange problems in a multithreaded environment.
    # We are forcing webrick to be single-thread.
    # This sucks but it's easier than writing a connection pool,
    # and most of these requests should be short-lived.
    ActiveRecord::Base.allow_concurrency = false
    
    # It's go time
    @server.start
  end
    
end