class FixVenueNames < ActiveRecord::Migration
  def self.up
    # Fix a few errors that have crept into the production data
    Venue.transaction do
      Venue.find(:all).each do  |v|
        v.name = v.name.squeeze(' ')
        v.name.gsub!(/&amp;/, '&')
        v.name.gsub!(/&apos;/, '\'')
        v.name.gsub!(/&quot;/, '"')
        v.name.gsub!(/\n/, '')
        v.short_name = Venue.name_to_short_name(v.name)
        v.save
      end
    end
  end

  def self.down
    raise IrreversibleMigration
  end
end
