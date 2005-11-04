class BandPublicController < ApplicationController
  before_filter :find_band
  layout "public"
  upload_status_for :create_logo
  
  # The the band homepage
  def index
    p params
  end
  
  def change_logo
    puts "here I am!"
    @band.update_attributes(params[:band])
    @band.save
    
    path = @band.logo_options[:base_url] + "/logo/" + @band.logo_relative_path
    finish_upload_status "'#{path}'"
  end
  
  def set_bio
    @band.bio = params[:value]
    @band.save
    render :text => @band.bio
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
