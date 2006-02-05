class AdminController < ApplicationController
  include FanLoginSystem
  
  before_filter :superuser_login_required
  before_filter :find_fan
  layout "public"
  
  def index
  end
  
  # TODO Tags
  def create_band
    if request.get?
      @band = Band.new
      return
    end
    
    @band = Band.new(params[:band])
    @band.claimed = false
    if @band.save
      flash[:success] = "Band created"
      redirect_to :action => 'create_band'
    end
  end
  
  def edit_band
    if request.get?
      @band = Band.find(params[:id])
      return
    end
    
    @band = Band.find(params[:id])
    @band.update_attributes(params[:band])
    if @band.save
      flash[:success] = "Band saved"
      redirect_to public_band_url(@band)
    end
  end
  
  private 
  
  def find_fan
    session[:fan] ||= Fan.new
    @fan = session[:fan]
  end
end
