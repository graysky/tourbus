class AdminController < ApplicationController
  include FanLoginSystem
  
  before_filter :superuser_login_required
  before_filter :find_fan
  layout "public"
  
  def index
  end
  
  def list_announcements
    @announcements = Announcement.find(:all)
  end
  
  def destroy_announcement
    Announcement.find(params[:id]).destroy
    flash[:success] = "Announcement deleted"
    redirect_to :action => 'list_announcements'
  end
  
  def create_announcement
    if request.get?
      @announcement = Announcement.new
      return
    end
    
    @announcement = Announcement.new(params[:announcement])
    if @announcement.save
      flash[:success] = "Announcement created"
      redirect_to :action => 'list_announcements'
    end
  end
  
  def edit_announcement
    if request.get?
      @announcement = Announcement.find(params[:id])
      return
    end
    
    @announcement = Announcement.find(params[:id])
    @announcement.update_attributes(params[:announcement])
    if @announcement.save
      flash[:success] = "Announcement saved"
      redirect_to :action => 'list_announcements'
    end
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
