require 'config/environment'

ps = PhotoSearch.new

bands = Band.find(:all, :order => "num_fans desc", :limit => 500)

bands.each do |b|
  begin
    ps.find_show_photos(b, 1.week.ago)
  rescue Exception => e
    OFFLINE_LOGGER.error e.to_s
    OFFLINE_LOGGER.error e.backtrace
  end
end