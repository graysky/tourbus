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
  
  #########
  # Private
  #########
  private
  
  def find_fan
    session[:fan] ||= Fan.new
    @fan = session[:fan]
  end
end
