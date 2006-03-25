class VenueShortName < ActiveRecord::Migration
  def self.up
    add_column :venues, :short_name, :string
    Venue.reset_column_information
    Venue.find(:all).each do |v|
      v.short_name = Venue.name_to_short_name(v.name)
      v.save
    end
  end

  def self.down
    remove_column :venues, :short_name
  end
end
