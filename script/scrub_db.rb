require 'config/environment'

# Scrub the database of info to make a drop of the production
# db ready to run for development. Currently:
# - cleans up email addresses
# - 
#
def fan_downtree?(fan)
  [Fan.mike, Fan.gary, Fan.admin].include?(fan)
end

def run

  bands = Band.find(:all)
  # Remove links to band images for local dev env
  bands.each do |b|
    if !b.logo.nil? and !b.logo.empty?
      puts "Fixing #{b.name} with email #{b.contact_email}"
      b.logo = nil
      b.contact_email = Emails.random
      b.save!
    end
  end

  fans = Fan.find(:all)  
  fans.each do |f|
    changed = false
    # Remove link to logo
    if !f.logo.nil? and !f.logo.empty?
      puts "Fixing logo for #{f.name}"
      f.logo = nil
      changed = true
    end
    
    if !fan_downtree?(f)
      puts "Fixing email for #{f.name}"
      f.contact_email = Emails.random
      changed = true
    end
    
    f.save! if changed
  end

end 

# Run the fix
run