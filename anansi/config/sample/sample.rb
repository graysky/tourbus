##
## Anansi config file
##

##
## Define data
## 

# The URL for this site - mandatory
# Can be single url:
set :url, "http://figureten.com/site/test.html"
#
# Or an array of URLs
# set :url, ["http://figureten.com/site/test.html", "http://figureten.com/site/test2.html"]
#
# Or as a Proc to embed month like "Feb" at the end
#set(:url)   { "http://figureten.com/page/#{ Time.now.strftime("%b") }" }
#

# A set of table columns
set :table_columns, { 0 => :date, 1 => :time, 2 => :bands, 
                  3 => :venue, 4 => :age_limit, 5 => :cost, 6 => :ignore }

# How often (in hours) to check the site                  
set :interval, 24

## 
## Define methods
##

# Define a new method
method :my_method  do

  # Can reference data defined earlier
  puts "my_method called - my name is #{name} with #{url}"

end

