
class Recommender
  attr_reader :band_fan_vectors
  attr_reader :band_sims
  
  def doit
    build_band_fan_vectors
    build_band_sims
    true
  end
  
  # Build a hash of fan-band vectors
  def build_band_fan_vectors
    @band_fan_vectors = {}
    
    # We only care about bands that have at least one fan and fans with at least one fave
    @bands = Band.find(:all, :conditions => 'num_fans > 0', :include => :fans)
    @fans = Fan.find(:all, :include => :bands).reject! { |fan| fan.bands.empty? }
  
    @bands.each do |band|
      vector = []
      
      @fans.each do |fan|
        vector << (fan.favorite?(band) ? 1 : 0)
      end
      
      @band_fan_vectors[band.id] = vector
    end
  end
  
  # Build a table of similar bands for each co-rated band in the system
  def build_band_sims
    @band_sims = {}
    
    @bands.each do |band|
      
      @band_sims[band.id] = []
      
      related_bands = []
      band.fans.each { |fan| related_bands += fan.bands }
      related_bands.uniq!
      
      sims = []
      related_bands.each do |related|
        next if related == band
        sim = calculate_similarity(band, related)
        sims << [related.id, sim, related.name]
      end
      
      sims.sort! do |x1, x2|
        x2[1] <=> x1[1]
      end
      
      @band_sims[band.id] = sims[0..5]
    end
  end

  def calculate_similarity(b1, b2)
    # Simplest cosine method
    vec1 = @band_fan_vectors[b1.id]
    vec2 = @band_fan_vectors[b2.id]
    
    dot_product(vec1, vec2) / (magnitude(vec1) * magnitude(vec2))
  end
  
  def dot_product(vec1, vec2)
    sum = 0
    for i in 0...vec1.size
      sum += (vec1[i] * vec2[i])
    end
    
    sum
  end
  
  def magnitude(vec)
    sum = 0
    vec.each { |n| sum += (n * n) }
    Math.sqrt(sum)
  end
  
end