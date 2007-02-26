# Schema as of Sun Feb 18 18:07:46 Eastern Standard Time 2007 (schema version 43)
#
#  id                  :integer(11)   not null
#  params              :text          
#  turk_site_id        :integer(11)   
#  token               :string(255)   
#

require 'yaml'

class TurkHitSubmission < ActiveRecord::Base
  belongs_to :turk_site
  
  MAX_SHOWS = 60
  
  def params=(p)
    write_attribute("params", YAML::dump(p))
  end
  
  def params
    YAML::load(read_attribute("params"))
  end
end
