# Note: When searching for a zip code using the find method, the id should be
# The zip code as a string: ZipCode.find("01721")
class ZipCode < ActiveRecord::Base
  set_primary_key "zip"
end
