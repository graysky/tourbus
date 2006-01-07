require 'ferret'

# Note: We will almost certainly want to cache results eventually
# We also may want to run the query first...
class LocationFilter < Ferret::Search::Filter
  include Ferret
  
  def initialize(ferret_class, center_lat, center_long, radius)
    @ferret_class  = ferret_class
    @center_lat = center_lat.to_f
    @center_long = center_long.to_f
    @radius = radius.to_f
  end
   
  def bits(reader)
    bits = Utils::BitVector.new()

    center_lat_radians = @center_lat * (Math::PI / 180)
    center_long_radians = @center_long * (Math::PI / 180)
    
    # FIXME This very inefficient.
    term_docs = reader.term_docs_for(Index::Term.new("ferret_class", @ferret_class.downcase))
    while term_docs.next?
      doc = reader.get_document(term_docs.doc)
      
      lat = doc["latitude"].to_f
      long = doc["longitude"].to_f
      
      lat_radians = lat * (Math::PI / 180)
      long_radians = long * (Math::PI / 180)
     
      # This is the spherical law of cosines
      x = (Math.sin(lat_radians) * Math.sin(center_lat_radians)) + (Math.cos(lat_radians) * Math.cos(center_lat_radians) * Math.cos(long_radians - center_long_radians))
      
      if x <= -1 or x >= 1
        # Cannot calculate acos
        distance = 0
      else
        distance = Math.acos(x) * 3963 # Radius of earth in miles
      end
      
      bits.set(term_docs.doc) if distance <= @radius
    end
    
    return bits
  end  
end