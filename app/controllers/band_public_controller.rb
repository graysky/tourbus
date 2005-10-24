class BandPublicController < ApplicationController
  before_filter :find_band
  layout "public"
  
  # The the band homepage
  def index
    
  end
  
  def shows
    
  end
  
  private
  def find_band
    @band = Band.find_by_band_id(params[:band])
  end
end
