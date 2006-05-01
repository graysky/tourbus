module FanPublicHelper
  def fan_bio_for_editing
    if @fan.bio != ""
      "<div id='fan_bio'>#{@fan.bio}</div>"
    else
      "<div id='fan_bio'></div>"
    end
  end
  
  # Format URL to be cleaner for display
  # Take: http://www.mysite.com/
  # Return: www.mysite.com
  def format_website(url)
    return "" if url.nil?
    
    url.sub!(/http:\/\//, '')
    url.sub!(/\/$/, '')
    return url
  end
end
