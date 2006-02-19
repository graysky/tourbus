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
    
    # FIXME This very inefficient.
    term_docs = reader.term_docs_for(Index::Term.new("ferret_class", @ferret_class.downcase))
    while term_docs.next?
      doc = reader.get_document(term_docs.doc)
      
      lat = doc["latitude"].to_f
      long = doc["longitude"].to_f
      
      next if lat == 0 and long == 0
      
      bits.set(term_docs.doc) if Address::is_within_range(lat, long, @center_lat, @center_long, @radius)
    end 
    
    return bits
  end  
end