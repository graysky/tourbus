# Parses a log file in apache standard format, and creates new LogEntries in the db.
class ApacheLogParser
  
  attr_accessor :file
  
  def initialize(file)
    @file = file
  end
  
  def parse
    File.open(@file) do |file|
      while (line = file.gets)
        parse_line(line)
      end
    end 
  end
  
  def parse_line(line)
    line =~ /(\d+\.\d+\.\d+\.\d+) ([^\s]+) ([^\s]+) \[(.*)\] "([^\s]+) ([^\s]+) (.*)" (\d+) (\d+) "([^\s]+)" "(.*)"/

    if $1.nil?
      puts "Skipping line: #{line}"
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