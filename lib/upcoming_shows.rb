# Mixin for model classes that have related shows
module UpcomingShows
  def upcoming_shows
    self.shows.find(:all, :conditions => ["date > ?", Time.now], :order => "date ASC")
  end
  
  def before_save
    super
    self.num_upcoming_shows = self.upcoming_shows.size
  end
end