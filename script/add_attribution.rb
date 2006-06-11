require 'config/environment'

c = AnansiConfig.new
c.start

Show.transaction do
  Show.find(:all).each do |show|
    puts show.id
    if show.created_by_system? && show.source_link.nil?
      
      visit = show.site_visit
      next if visit.nil? || visit.name.starts_with?('tts') || visit.name.starts_with?('pas')
    
      site = c.site_by_name(visit.name)
      next if site.nil? 
      
      show.source_name = site.display_name
      show.source_link = site.display_url
      
      p "Set: #{show.source_name}, #{show.source_link}"
      
      show.save!
    end
  end
end