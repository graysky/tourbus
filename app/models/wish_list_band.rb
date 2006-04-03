class WishListBand < ActiveRecord::Base
  def after_save
    super
    self.short_name = Band.name_to_id(self.name)
  end
end
