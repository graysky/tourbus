class BandPublicController < ApplicationController
  before_filter :find_band
  layout "public"
  #upload_status_for :create_logo
  
  # The the band homepage
  def index
    p params
  end
  
  def change_logo
    p "hi"
    p params[:band]
    p @band
  end
  
  private
  def find_band
    # temp: fix tihs
    @band = Band.find_by_band_id(params[:band_id])
    if @band.nil?
      @band = session[:band]
    end
    
  end
end
