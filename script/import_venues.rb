require 'yaml'

cmd = <<END

YAML::load_documents(File.open("db/all_venues.yaml")) do |v|
  v["venues"].each do |hash|
    if hash["name"].chomp!(", The")
      hash["name"] = "The " + hash["name"]
    end
    puts "Saving " + hash["name"]
    Venue.new(hash).save
    
  end
end

END

system "ruby ./script/runner '#{cmd}'"