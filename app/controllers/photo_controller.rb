class PhotoController < ApplicationController
  helper :comment
  helper :tag
  upload_status_for :upload_photo
  layout "public"
  
  def upload_photo
    photo = Photo.new(params[:photo])
    
    case params[:type]
    when Photo.Band then photo.band = Band.find_by_id(params[:id])
    when Photo.Show then photo.show = Show.find_by_id(params[:id])
    when Photo.Venue then photo.venue = Venue.find_by_id(params[:id])
    end
    
    photo.created_by_band_id = logged_in_band if logged_in_band
    photo.created_by_fan_id = logged_in_fan if logged_in_fan
    photo.save
    
    str = render_to_string(
	:partial => "photo/photo_preview_contents", 
	:locals => 
		{
		:photo => photo,
		})
    
    # Escape single quotes (TODO Factor out)
    str.gsub!(/["']/) { |m| "\\#{m}" }
    path = photo.relative_path("preview");
    finish_upload_status "'#{str}'"
  end
  
  def show_one
    @photo = Photo.find(params[:photo_id])
    @name = params[:name]
    @showing_creator = params[:showing_creator]
  end
  
  def set_caption
    @photo = Photo.find(params[:id])
    @photo.description = params[:value]
    @photo.save
    render :text => @photo.description
  end
end
