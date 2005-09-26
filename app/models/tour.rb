class Tour < ActiveRecord::Base
  belongs_to :band
  has_many :shows
end
