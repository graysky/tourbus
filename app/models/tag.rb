class Tag < ActiveRecord::Base
  has_and_belongs_to_many :bands

  validates_presence_of :name
  validates_uniqueness_of :name
  
  # Find all tags with count of # bands applied to, ordered by count
  def self.find_all_with_count
    self.find_by_sql("SELECT t.*, COUNT(bt.band_id) AS count FROM tags t, tags_bands bt WHERE bt.tag_id = t.id GROUP BY t.id ORDER BY count DESC;")
  end
  
  # Returns an integer count, ONLY when the tag was loaded with find_all_with_count
  def count
    Integer(read_attribute("count"))
  end
end
