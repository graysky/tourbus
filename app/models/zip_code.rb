# Schema as of Sun Feb 18 18:07:46 Eastern Standard Time 2007 (schema version 43)
#
#  id                  :integer(11)   not null
#  zip                 :string(16)    default(0), not null
#  city                :string(30)    default(), not null
#  state               :string(30)    default(), not null
#  latitude            :float         default(0.0), not null
#  longitude           :float         default(0.0), not null
#  timezone            :integer(2)    default(0), not null
#  dst                 :boolean(1)    not null
#  country             :string(2)     default(), not null
#

# Note: When searching for a zip code using the find method, the id should be
# The zip code as a string: ZipCode.find("01721")
class ZipCode < ActiveRecord::Base
  set_primary_key "zip"
end
