require 'erb'

class TurkHitType < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :price
  validates_presence_of :title
  validates_presence_of :description
  
  DEFAULT_QUESTION_TEMPLATE = "ataturk/questions/_default.erb"
  
  def question(site)
    file = "#{self.name}.erb"
    file = DEFAULT_QUESTION_TEMPLATE if !File.exists?(file)
    
    e = ERB.new(File.read(file))
    e.result(binding)
  end
  
end