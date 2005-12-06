class PhotoController < ApplicationController
  upload_status_for :upload_photo
  
  def upload_photo
    photo = Photo.new(params[:photo])
    
    case params[:type]
    when Photo.Band then photo.band = Band.find_by_id(params[:id])
    when Photo.Show then photo.show = Show.find_by_id(params[:id])
    end
    
    photo.created_by_band_id = logged_in_band if logged_in_band
    photo.created_by_fan_id = logged_in_fan if logged_in_fan
    photo.save
    
    path = photo.relative_path("preview");
    finish_upload_status "'#{path}'"
  end
end
