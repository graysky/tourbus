require 'config/environment'

def run

  bands = Band.find(:all)
  # Remove links to band images for local dev env
  bands.each do |b|
    if !b.logo.nil? and !b.logo.empty?
      puts "Fixing #{b.name}"
      b.logo = nil
      b.save!
    end
  end

  fans = Fan.find(:all)  
  fans.each do |f|
    if !f.logo.nil? and !f.logo.empty?
      puts "Fixing #{f.name}"
      f.logo = nil
      f.save!
    end
  end

end 

# Run the fix
run