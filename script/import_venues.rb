require 'yaml'

cmd = <<END

YAML::load_documents(File.open("db/all_venues.yaml")) do |v|
  v["venues"].each do |hash|
    if hash["name"].chomp!(", The")
      hash["name"] = "The " + hash["name"]
    end
    hash["url]" = "" if hash["url"].nil?
    puts "Saving " + hash["name"]
    v = Venue.new(hash)
    v.save
    v.ferret_save
    
    
  end
end

END

system "ruby ./script/runner '#{cmd}'"