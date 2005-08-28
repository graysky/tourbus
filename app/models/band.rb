class Band < ActiveRecord::Base
  has_and_belongs_to_many :tags
  has_many :shows
  
  validates_presence_of :name, :contact_email, :url, :zipcode
  validates_uniqueness_of :name, :url
end
