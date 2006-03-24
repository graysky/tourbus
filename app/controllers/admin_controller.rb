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
   
    # Add all the links
    links = extract_links(params, @band)
    links.each { |link| @band.links << link }
    
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
      
      prepare_links(@band.links)
      return
    end
        
    @band = Band.find(params[:id])
    @band.update_attributes(params[:band])

    # Split the tags
    tags = params[:tags]

    @band.apply_tags(tags, Tag.Band)

    # Add all the links
    links = extract_links(params, @band)
    links.each { |link| @band.links << link }
  
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
  
  def list_shows_to_import
    load_shows #if @session[:shows_by_status].nil?
  end
  
  def shows_by_status
    load_shows
    @shows = @shows_by_status[params['status'].to_sym]
  end
  
  def edit_import_show
    load_shows
   
    id = params[:id]
    @shows_by_status.each do |status, list|
      i = 0
      list.each do |show|
        if show[:id].to_s == id
          @show = show
          break
        end
        
        i += 1
      end
    end
    
    return if request.get?
    
    status = @show[:status]
    reconstruct_show_hash(@show)
    set_ok(@show) if params['do_ok'] == 'true'
    import_show(@show) if params['do_import'] == 'true'
    
    importer = AnansiImporter.new
    importer.save_shows_by_status(@shows_by_status)
    
    redirect_to :action => :shows_by_status, :status => status.to_s
  end
  
  def load_shows
    importer = AnansiImporter.new
    shows = importer.latest_prepared_shows
    
    @shows_by_status = {}
    for show in shows
      list = @shows_by_status[show[:status]] ||= []
      list << show
    end
  end
  
  private 
  
  # Prepare instance vars for the form to display
  def prepare_links(links)
  
    num = 1
    links.each do |link|
    
      name_var = "name_link#{num}"
      url_var = "url_link#{num}"
    
      # Hack to set "@name_link1" so that the form will make editing easy
      self.instance_variable_set( "@#{name_var}", link.name)
      self.instance_variable_set( "@#{url_var}", link.data)
      
      num = num + 1
    end
  end
  
  # Pull out the links from the params array and
  # return an array of Links
  def extract_links(params, band = nil)
  
    links = []
    
    # Try to find all the links in the param
    (1..8).each do |num|
      
      name_key = "name_link" + num.to_s
      url_key = "url_link" + num.to_s
      
      name = params[name_key.to_sym]
      url = params[url_key.to_sym]
      
      # Don't add it's empty
      break if name.empty? or url.empty?
      
      # Create the new link
      link = Link.new
      link.name = name
      link.data = url
      
      links << link
    end
    
    return links
  end
  
  def import_show(show)
    importer = AnansiImporter.new
    new_show = importer.import_show(show)
    new_show.ferret_save
    set_ok(show)
  end
  
  def set_ok(show)
    show[:status] = :ok
    show[:explanation] = ''
  end
  
  def reconstruct_show_hash(orig)
    set_if_overriden(:age, orig, params)
    set_if_overriden(:cost, orig, params)
    set_if_overriden(:preamble, orig, params)
    orig[:venue][:id] = params['venue_id']
    
    orig[:bands].each_with_index do |band, i|
      orig[:bands][i][:name] = params["band#{i}_name"]
      orig[:bands][i][:url] = params["band#{i}_url"]
      orig[:bands][i][:extra] = params["band#{i}_extra"]
    end
    
  end
  
  def set_if_overriden(key, orig, override)
    orig[key] = override[key.to_s] if override.has_key?(key.to_s)
  end
  
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
