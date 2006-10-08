# Parses a log file in apache standard format, and creates new LogEntries in the db.
class ApacheLogParser
  
  attr_accessor :file
  attr_accessor :skip_old
  
  # uncompress, parse and compress the given file
  def self.parse_archive(f)
    `gzip -d #{f}.gz`
    begin
        p = ApacheLogParser.new(f)
        p.parse
    rescue Exception => e
      RAILS_DEFAULT_LOGGER.error(e.to_s)
    ensure
        # Temp for debugging
        #`gzip #{f}`
    end
  end
  
  def initialize(file)
    @file = file
    @skip_old = true
    @last_entry = nil
    @skipped = 0
  end
  
  def parse
    RAILS_DEFAULT_LOGGER.info("Parsing apache logs...")
    
    @skipped = 0
    
    if @skip_old
      @last_entry = LogEntry.find(:first, :order => "date DESC", :limit => 1)
    end
    
    File.open(@file) do |file|
      while (line = file.gets)
        parse_line(line)
      end
    end
    
    if @skip_old
      puts "Skipped: #{@skipped}"
    end 
  end
  
  def parse_line(line)
    line =~ /(\d+\.\d+\.\d+\.\d+) ([^\s]+) ([^\s]+) \[(.*)\] "([^\s]+) ([^\s]+) (.*)" (\d+) (-|\d+) "([^\s]+)" "(.*)"/
    
    if $1.nil?
      puts "Invalid line: #{line}"
      return
    end

    e = LogEntry.new
    
    e.ip = $1
    e.host = $2
    e.date = get_date($4)
    e.method = $5
    e.url = $6
    e.http_ver = $7
    e.status = $8
    e.bytes = $9.to_i
    e.referrer = $10
    e.browser = $11
    
    if @skip_old && @last_entry && @last_entry.date >= e.date
      @skipped += 1
      return
    end
    
    # filter out thinks we don't care about
    if e.url =~ /\.png|\.gif|\.js|\.jpg|\.ico|\.css/
      return
    end
    
    e.save!
  end
  
  def get_date(str)
    chunks = str.split(":")
    d = Date.strptime(chunks[0], "%d/%b/%Y")
        
    hour = chunks[1]
    min = chunks[2]
    sec = chunks[3].split[0]
    
    Time.local(d.year, d.month, d.mday, hour, min, sec)
  end
end