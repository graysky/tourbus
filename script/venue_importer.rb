require 'config/environment'
require 'yaml'

file = "db/venues.yml"

venues = YAML::load(File.new(file))

venues.each do |name, v|
  
  found = Venue.find_by_latitude_and_longitude(v[:latitude], v[:longitude])
  if found || v[:latitude].nil?
    puts "Skipped #{v[:name]}"
    next
  end
  
  venue = Venue.new
  venue.name = v[:name]
  venue.short_name = Venue.name_to_short_name(venue.name)
  venue.url = v[:url] || ""
  venue.set_location_from_hash(v)
  
  venue.save!
  venue.ferret_save
  
  puts "Added #{venue.name}"
end