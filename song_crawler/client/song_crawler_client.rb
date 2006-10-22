require 'socket'
require 'fileutils'
require 'uri'
require 'find'
require 'vendor/id3/id3'
require 'net/http'
require 'open-uri'
require 'rexml/document'
require 'logger'
require 'song_crawler/song_crawler_base'
require 'monitor'

# TODO: threads, deletion
# Maybe: Parse m3u's?
class SongCrawlerClient
  include REXML
  include SongCrawlerBase
  
  MIN_FILE_SIZE = 512 * 1024 # bytes
  
  class RemoteException < RuntimeError
    attr :code
    def initialize(code)
      @code = code
    end
  end
  
  def initialize(opts = {})
    @options = default_options
    opts.each do |key, value|
      @options[key] = value
    end
    
    @worker_id = Socket.gethostname
    
    uri = URI.parse(@options[:server])
    @host = uri.host
    @port = uri.port
    @journal = Journal.new("logs")
  end  
  
  def default_options
    opts = {
      :directory => "song_crawler_data",
      :server => "http://tourb.us:9863"
    }
  end
  
  ####
  # Main entrypoint
  ####
  def start
    FileUtils.mkpath(@options[:directory])
    Dir.chdir(@options[:directory])
    
    @logger = Logger.new("logs/client.log", 3, 1024 * 1024)
    @logger.level = Logger::DEBUG
    
    @journal.init
    recover
    
    @logger.info("Starting client for service: http://#{@host}:#{@port}")
    
    while (true)
      url, id = get_work
      
      @logger.info "Starting work on site #{id}: #{url}"
      error = false
      comment = ""
      count = 0
      begin
        log = "logs/#{id}.log"
        
        success = system(wget_cmd(url, log))
        if !success
          comment = "" # Comment not really useful now
          error = true
        end
        
        # Always check for songs
        count = find_songs(id, url)
      ensure
        # Stop crawling
        @logger.info "Finished with site #{id}"
        finish_crawl(id, url, error, comment, count)
      end
    end
  end
  
  # Recover from previous crawls
  def recover
    for crawl in @journal.crawls
      @logger.info("Aborting crawl: #{crawl[0]}, #{crawl[1]}")
      count = find_songs(crawl[0], crawl[1])
      finish_crawl(crawl[0], crawl[1], true, "Aborted", count)
    end
  end
  
  # Get a site to crawl from the server.
  # Will not return until there is work to do.
  def get_work
    doc = nil
   
    begin
      doc = send_request("/get_work?worker=#{@worker_id}")
    rescue RemoteException => re
      if re.code == ERROR_NO_WORK
        sleep 30
        retry
      end
    rescue Exception => e
      # Maybe a connection error...
      @logger.error e.to_s
      sleep 30
      retry
    end
     
    url, id = doc.get_text("success/site/url"), doc.get_text("success/site/id")
    @journal.add_crawl(id.to_s, url.to_s)
    return url,id
  end
  
  # Stop crawling and release the site
  def finish_crawl(site, url, error, comment, count)
    begin
      send_request("/finish_crawl?site=#{site}&worker=#{@worker_id}&error=#{error}&comment=#{comment}&count=#{count}")
    rescue Exception => e
      @logger.error e.to_s
    ensure
      @journal.remove_crawl(site.to_s, url.to_s)
    end
  end
  
  # Send a remote reqeust
  def send_request(url)
    response = open("http://#{@host}:#{@port}#{url}")
    doc = Document.new(response.read)
    
    @logger.debug(doc.to_s)
    
    if doc.root.name == "error"
      code = doc.get_text('error/code').to_s
      msg = "Request error #{code}: #{doc.get_text('error/msg').to_s} (#{url})"
      raise RemoteException.new(code.to_i), msg
    end
    
    doc
  end
  
  def wget_cmd(url, log)
    domain = get_domain(url)
    
    reject = "exe,avi,mov,mpg,mpeg,tiff,bmp,zip,gz,jpg,JPG,GIF,jpeg,gif,png,pdf,psd,css,js,swf,rm,\"*viewtopic*\",\"*viewforum*\""
    reject << ",\"*login.php*\",\"*privmsg.php*\",\"*phpBBb*\""
    excluded_domains = "boards.#{domain},blog.#{domain},board.#{domain}"
    excluded_dirs = "/board,/boards,/messageboards,/messageboard,/rss,/phpBB2"
    
    "wget -r -w 1 -H -D#{domain} --exclude-domains #{excluded_domains} -X #{excluded_dirs} -N -R #{reject} -o #{log} #{url}"
  end
  
  # Find all songs that we downloaded from this url
  def find_songs(id, url)
    count = 0
    
    # Check for any subdomain of the url
    domain = get_domain(url)
   
    Find.find(".") do |f|
      Find.prune if !(f == "." || f.index(domain))
      
      if File.file?(f) && (File.stat(f).size >= MIN_FILE_SIZE || f =~ /\.mp3$/)
        
        if ID3.hasID3tag?(f)
          begin
            a = ID3::AudioFile.new(f)
          rescue Exception => e
            @logger.error("Can't get id3: #{e}, #{f}")
            next
          end
          
          artist = a.value('artist')
          if artist && artist != ""
            url = "http://" + f.slice(2, f.length)
            song = { :artist => artist, 
                     :title => a.value('title'),
                     :album => a.value('album'),
                     :year => a.value('year'),
                     :size => File.stat(f).size,
                     :url => url }
            
            # Send songs to the server as we find them.
            send_songs(id, [song])
            count += 1
          end

        end
      end
    end
    
    count
  end
  
  def get_domain(url)
    u = URI.parse(url.to_s)
    parts = u.host.split(".")
    
    if parts[-1] == "uk"
      return parts[-3] + "." + parts[-2] + "." + parts[-1]
    else
      return parts[-2] + "." + parts[-1]
    end
  end
  
  def send_songs(id, songs)
    # Build the XML representation of songs
    xml = "<songs>"
    songs.each do |song|
      xml << "<song>"
      song.each do |attr, value|
        xml << "<#{attr.to_s}>#{cdata(value)}</#{attr.to_s}>"
      end
      xml << "</song>"
    end
    xml << "</songs>"
    
    Net::HTTP.start(@host, @port) do |http|
      res = http.post("/add_songs", get_request_xml(id, xml))
      doc = Document.new(res.body)
      
      if doc.root.name == "error"
        # Print a warning but keep going
        # TODO Collect up failures and retry in a thread
        @logger.warn "Error uploading song info: #{doc.get_text('error/code')}: #{doc.get_text('error/msg').to_s}"
      end
    end
  end

  def get_request_xml(site_id, xml)
    "<request><worker>#{@worker_id}</worker><site>#{site_id}</site>#{xml}</request>"
  end  
end

# Journal our progress  
class Journal
  attr_reader :crawls
  
  def initialize(dir)
    @dir = dir
    @file = "#{dir}/.journal"
    @crawls = []
    @lock = Monitor.new
  end
  
  def init
    if File.exists?(@file)
      IO.foreach(@file) do |line|
        line.strip!
        if line != ''
          c = line.split("|")
          c[0].strip!
          c[1].strip!
          crawls << c
        end
      end
    end
  end
  
  def add_crawl(id, url)
    @lock.synchronize do
      @crawls << [id.strip, url.strip]
      save
    end
  end
  
  def remove_crawl(id, url)
    @lock.synchronize do
      @crawls.each do |c|
        if c[0] == id.strip && c[1] == url.strip
          @crawls.delete(c)
          break
        end
      end
      save
    end
  end 

  protected
  
  def save
    File.open(@file, "w") do |f|
      @crawls.each do |url| 
        if url[0] && url[1]
          f << url[0] + "|" + url[1] + "\n"
        end
      end
    end
  end
end

# Extend the audiofile class
class ID3::AudioFile
  def value(name)
    tags = self.tagID3v2
    val = ""
    if tags
      v = tags[name.upcase]
      val = v["text"] if v
    else
      tags = self.tagID3v1
      if tags
        val = tags[name.upcase]
      end 
    end
    
    val ? val.strip : ""
  end
end
