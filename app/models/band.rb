class Band < ActiveRecord::Base
  has_and_belongs_to_many :tags
  
  validates_presence_of :name, :contact_email
  validates_uniqueness_of :name
end
