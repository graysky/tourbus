# Convert all existing bands to use the new Links
class ConvertBandUrls < ActiveRecord::Migration
  def self.up
  
    # For each band see if they have an official URL and if so, convert
    # it to use the Links
    Band.find(:all).each do |band|
    
      next if band.official_website.empty?
      
      #puts "Band URL: #{band.official_website}" 
      
      # Create the new link
      link = Link.new
      
      link.data = band.official_website
      link.name = "Official Website"
      band.links << link
      
      # Clear the old value
      band.official_website = ""
      
      band.save!
    end
    
    # Remove the old column
    remove_column :bands, :official_website
    
  end

  def self.down
    # Can't unconvert the data
    raise IrreversibleMigration
  end
end
