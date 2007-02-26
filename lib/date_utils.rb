class DateUtils
  
  # The parsed date, with the year guessed if not available.
  # nil if unparseable
  def self.parse_date_loosely(str)
    return nil if str.blank?
    
    str.gsub!(/(\.|-)/, '/')
  
    values = ParseDate.parsedate(str, true)
    
    # Need at least a month and a date. Assume this year (for now)
    if values[1].nil? or values[2].nil?
      return nil
    end
    
    if values[0].nil? or values[0] != Time.now.year or values[0] != Time.now.year + 1
      if Time.now.month > 8 && values[1] < 3
        values[0] = Time.now.year + 1
      else
        values[0] = Time.now.year
      end
    end
    
    Time.local(values[0], values[1], values[2]) rescue nil
  end

end
