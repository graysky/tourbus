## 
## Anansi config file
##
#
#
# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

#
# set :name # Defaults to name of this config file
#
# The URL for this site - mandatory
# Can be single url:
set :url, "http://figureten.com/site/test.html"
#
# Or an array of URLs
# set :url, ["http://figureten.com/site/test.html", "http://figureten.com/site/test2.html"]
#
# Or as a Proc to embed month like "Feb" at the end
# set(:url) { "http://figureten.com/page/#{ Time.now.strftime("%b") }" }
#

# How often (in hours) to check the site (can set to 0 to force checking everytime)
set :interval, 3

# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================
#

# A set of table columns
set :table_columns, { 0 => :date, 1 => :time, 2 => :bands, 
                  3 => :venue, 4 => :age_limit, 5 => :cost, 6 => :ignore }


# =============================================================================
# DEFINE METHODS
# =============================================================================
#

# Define a new method - have to set how many args
method :parse_venue, {:args => 2} do |foo, bar|

  # Can reference data defined earlier
  puts "Site's method called with #{foo} and #{bar}"
  puts "And can ref vars defined above like url #{url}"
end

