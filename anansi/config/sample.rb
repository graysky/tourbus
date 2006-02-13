##
## Anansi config file
##

# The URL for this site
# Can be single url:
set :url, "http://figureten.com/site/test.html"

set :interval, 24

# Or an array of URLs
#set :url, ["http://tourb.us/shows", "http://new"]

# A set of table columns
set :table_columns, { 0 => :date, 1 => :time, 2 => :bands, 
                  3 => :venue, 4 => :age_limit, 5 => :cost, 6 => :ignore }

