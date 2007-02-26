# Schema as of Sun Feb 18 18:07:46 Eastern Standard Time 2007 (schema version 43)
#
#  id                  :integer(10)   not null
#  ip                  :string(16)    
#  host                :string(100)   
#  date                :datetime      
#  method              :string(4)     
#  url                 :string(100)   
#  http_ver            :string(16)    
#  status              :string(4)     
#  bytes               :integer(10)   
#  referrer            :string(100)   
#  browser             :text          
#

class LogEntry < ActiveRecord::Base
end
