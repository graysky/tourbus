class FlickrPhoto < ActiveRecord::Base
  belongs_to :show
  belongs_to :band
  belongs_to :venue
  
  def photopage_url
    read_attribute("photopage_url").gsub(/ /, '')
  end
  
  def guess_show_date
    hour = self.date.hour
    hour < 10 ? (self.date - 12.hours) : self.date
  end
end