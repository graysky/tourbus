class FanController < ApplicationController
 include FanLoginSystem
  
  before_filter :fan_login_required
  before_filter :find_fan
  layout "public"
  
  def index
  end
  
  def logout
    session[:fan] = nil
    redirect_to(:controller => "public", :action => "front_page")
  end
  
  def settings
     return if @request.get?
     
    @fan.update_attributes(params[:fan])
    if @fan.save
      flash[:notice] = "Settings updated"
    else
      # TODO GOTO ERROR
      flash[:notice] = "error"
    end
    
  end
  
  def add_favorite_band
    band = Band.find(params[:id])
    
    # If it's already a favorite then something went wrong, maybe someone just typed in the URL
    return if @fan.has_favorite(band)
    
    @fan.bands << band
    @fan.save!
    
    render :partial => "shared/remove_favorite"
  end
  
  def remove_favorite_band
    band = Band.find(params[:id])
    @fan.bands.delete(band)
    @fan.save!
    
    render :partial => "shared/add_favorite"
  end
  
  #########
  # Private
  #########
  private
  
  def find_fan
    session[:fan] ||= Fan.new
    @fan = session[:fan]
  end
end
