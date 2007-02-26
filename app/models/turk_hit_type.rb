# Schema as of Sun Feb 18 18:07:46 Eastern Standard Time 2007 (schema version 43)
#
#  id                  :integer(11)   not null
#  aws_hit_type_id     :string(255)   
#  name                :string(255)   
#  price               :integer(11)   
#  title               :string(255)   
#  description         :string(255)   
#  duration            :integer(11)   default(3600)
#  keywords            :string(255)   
#

require 'erb'

class TurkHitType < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :price
  validates_presence_of :title
  validates_presence_of :description
  
  DEFAULT_QUESTION_TEMPLATE = "ataturk/questions/_default.erb"
  
  def question_content(site)
    file = "#{self.name}.erb"
    file = DEFAULT_QUESTION_TEMPLATE if !File.exists?(file)
    
    e = ERB.new(File.read(file))
    e.result(binding)
  end
  
end
