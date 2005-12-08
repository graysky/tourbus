class FanPublicController < ApplicationController
  before_filter :find_fan
  helper :show
  helper :map
  helper :tag
  helper :photo
  upload_status_for :change_logo
  
  layout "public"
  
  def index
  
  end
  
  def change_logo
    @fan.update_attributes(params[:fan])
    @fan.save
    
    path = "/" + @fan.logo_options[:base_url] + "/" + @fan.logo_relative_path
    finish_upload_status "'#{path}'"
  end
  
  # do we really need a real name?
  def set_real_name
    @fan.real_name = params[:value]
    @fan.save
    render :text => @fan.bio
  end
  
  def photo
    render_component :controller => "photo", :action => "show_one", 
                     :params => {"photo_id" => params[:photo_id], 
                                 "name" => @fan.name, 
                                 "showing_creator" => true}
  end
  
  private
  def find_fan
    @fan = Fan.find_by_name(params[:fan_name])
    if @fan.nil?
      raise "No such fan. Put up an error screen"
    end
    
   if logged_in_fan
    @logged_in_as_fan = (logged_in_fan.id == @fan.id)
   end
   
   @fan
  end
end
