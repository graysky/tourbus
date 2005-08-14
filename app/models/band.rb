class Band < ActiveRecord::Base
  validates_presence_of :name, :contact_email
  validates_uniqueness_of :name
end
