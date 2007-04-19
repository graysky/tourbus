require 'config/environment'

ps = PhotoSearch.new

bands = Band.find(:all, :order => "num_fans desc", :limit => 400)

bands.each do |b|
  begin
    ps.find_show_photos(b)
  rescue Exception => e
    puts e
    puts e.backtrace
  end
end