require 'uuidtools'

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
  
  def create_band
    if request.get?
      @band = Band.new
      return
    end
    
    @band = Band.new(params[:band])
    
    # Split the tags
    tags = params[:tags]
    
    @band.apply_tags(tags, Tag.Band)
    
    @band.claimed = false
    @band.uuid = UUID.random_create.to_s
    if @band.save
      flash[:success] = "Band created"
      redirect_to :action => 'create_band'
    end
  end
  
  def edit_band
    if request.get?
      @band = Band.find(params[:id])

      # Make the tags available for editing
      tmp = @band.tags.map {|t| t.name }
      @tags = tmp.join(',')
      return
    end
        
    @band = Band.find(params[:id])
    @band.update_attributes(params[:band])

    # Split the tags
    tags = params[:tags]

    @band.apply_tags(tags, Tag.Band)

    if @band.save
      flash[:success] = "Band saved"
      redirect_to public_band_url(@band)
    end
  end
  
  def create_venue
    if request.get?
      @venue = Venue.new
      return
    end
    
    @venue = Venue.new(params[:venue])
    save_venue
  end
  
  def edit_venue
    if request.get?
      @venue = Venue.find(params[:id])
      return
    end
    
    @venue = Venue.find(params[:id])
    @venue.update_attributes(params[:venue])
    save_venue
  end
  
  def delete_venue
    @venue = Venue.find(params[:id])
    if @venue.shows.empty?
      Venue.delete(params[:id])
      flash.now[:success] = "It's gone"
    else
      flash.now[:error] = "That venue has shows"
    end
  end
  
  private 
  
  def save_venue
    result = Geocoder.yahoo(@venue.address_one_line)
    
    if result && result[:precision] == "address"
      @venue.set_location_from_hash(result)
    else
      flash.now[:error] = "Bad address"
    end
    
    if @venue.save
      @venue.ferret_save
      flash[:success] = "Venue saved"
      redirect_to public_venue_url(@venue)
    else
      flash.now[:error] = "Error saving"
    end
  end
  
  def find_fan
    session[:fan] ||= Fan.new
    @fan = session[:fan]
  end
end
