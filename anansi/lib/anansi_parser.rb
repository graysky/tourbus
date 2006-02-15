# Runs stage 2 of the anansi system. 
class AnansiParser

  # set testing to true if this is a test run
  def initialize(testing = false)
    @testing = testing
    @sites = []
    @config = nil
  end
  
  # Look for the configs in the given directory
  def start(config_dir)
    @config = AnansiConfig.new(@testing) 
    @config.start(config_dir)
    @sites = @config.sites
  end
  
  # Parse the configs found by the start method
  def parse
    @sites.each do |site| 
      puts "Begin parsing site #{site.name}"
    end
  end
end