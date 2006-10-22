require 'uuidtools'

class AdminController < ApplicationController
  include FanLoginSystem
  
  before_filter :superuser_login_required
  before_filter :find_fan
  layout "public"
  
  def index
  end
  
  def list_announcements
    @announcements = Announcement.find(:all, :conditions => ["updated_at > ?", Time.now - 6.months], :order => "updated_at DESC")
  end
  
  def list_comments
    # Last week's worth of comments
    @comments = Comment.find(:all, :conditions => ["created_on > ?", Time.now - 7.days], :order => "created_on DESC")
  end
  
  def list_photos
    # Last week's worth of photos
    @photos = Photo.find(:all, :conditions => ["created_on > ?", Time.now - 7.days], :order => "created_on DESC")
  end
  
  def list_active_fans
    # Show last 2 days of fan logins
    @fans = Fan.find(:all, :conditions => ["last_login > ?", Time.now - 2.days], :order => "last_login DESC")
  end
  
  def list_fans
    @fans = Fan.find(:all)
  end

  def fan_signups_by_day
    @fans = Fan.find_by_sql("select DATE(created_on) as date, count(*) as count from fans group by 1")
  end

  def list_system_events
    @events = SystemEvent.find(:all, :order => "created_at DESC")
  end

  # Track recently added shows by fans and bands  
  def list_added_shows
    go_back = 7.days # How many days to go back
    @fan_shows = Show.find(:all, :conditions => ["created_by_fan_id is not null AND created_on > ?", Time.now - go_back], :order => "created_on ASC")
    @band_shows = Show.find(:all, :conditions => ["created_by_band_id is not null AND created_on > ?", Time.now - go_back], :order => "created_on ASC")
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
      logger.info "Admin created a band: #(@band.name}"
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
      logger.info "Admin edited a band: #{@band.name}"
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
    @venue.short_name = Venue.name_to_short_name(@venue.name)
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
      @venue.ferret_destroy
      logger.info "Admin deleted venue #{@venue.name}"
      flash.now[:success] = "It's gone"
    else
      flash.now[:error] = "That venue has shows"
    end
  end
  
  def bulk_fan_mailer
    return if request.get?
    
    begin
      fans = eval(params[:code])
    
      fans.each do |fan|
        if !fan.is_a?(Fan)
          flash.now[:error] = "NOT A FAN: #{fan}"
          return
        end
      end
    rescue Exception => e
      flash.now[:error] = e.to_s
      return
    end
    
    logger.info("Sending bulk mail to: #{fans.collect { |f| f.contact_email }.join(',')} ")
    logger.info("Subject: #{params[:subject]}")
    logger.info("Body: #{params[:body]}")
    
    fans.each do |fan|
      FanMailer.deliver_bulk_mail(fan.contact_email, params[:subject], params[:body])
    end
    
    flash.now[:success] = "mail sent"
  end
  
  def list_shows_to_import
    load_shows #if @session[:shows_by_status].nil?
  end
  
  def shows_by_status
    load_shows
    @shows = @shows_by_status[params['status'].to_sym]
  end
  
  def top_venues_for_review
    load_shows
    shows = @shows_by_status[:review]
    
    @venues = {}
    for show in shows
      venue = show[:venue][:name]
      next if venue.blank?
      
      city = show[:venue][:city] || ""
      state = show[:venue][:state] || ""
      
      str = "<b>#{venue.downcase}</b>" + " in " + city.downcase + ", " + state.downcase
      count = @venues[str]
      count = 0 if count.nil?
      @venues[str] = count + 1
    end
    
    @venues = @venues.sort { |a, b| b[1] <=> a[1] }
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
    #if @session[:shows_by_status]
    #  @shows_by_status = @session[:shows_by_status]
    #  return
    #end
    
    importer = AnansiImporter.new
    shows = importer.latest_prepared_shows
    
    @shows_by_status = {}
    for show in shows
      list = @shows_by_status[show[:status]] ||= []
      list << show
    end
    
    #@session[:shows_by_status] = @shows_by_status
  end
  
  def add_song_sites
    return if request.get?
    
    sites = params[:sites].split(",")
    for site in sites
      site.strip!
      if SongSite.find_by_url(site).nil?
        SongSite.new(:url => site).save!
      end
    end
    
    flash.now[:success] = "Sites added and ready for crawling"
  end
  
  def show_song_sites
    filter = params[:filter] || "all"
    
    if filter == "active"
      conditions = "crawl_status = #{SongSite::CRAWL_STATUS_ACTIVE}"
    elsif filter == "disabled"
      conditions = "crawl_status = #{SongSite::CRAWL_STATUS_DISABLED}"
    else
      conditions = nil
    end
    
    @sites = SongSite.find(:all, :conditions => conditions)
  end
  
  def show_songs
    @songs = Song.find(:all, :order => "created_at desc")
  end
  
  private 
  
  # Prepare instance vars for the form to display
  def prepare_links(links)
  
    num = 1
    links.each do |link|
    
      name_var = "name_link#{num}"
      url_var = "url_link#{num}"
      id_var = "id_link#{num}"
    
      # Hack to set "@name_link1" so that the form will make editing easy
      self.instance_variable_set( "@#{name_var}", link.name)
      self.instance_variable_set( "@#{url_var}", link.data)
      self.instance_variable_set( "@#{id_var}", link.id)
      
      num = num + 1
    end
  end
  
  # Pull out the links from the params array and
  # return an array of Links
  def extract_links(params, band = nil)
  
    new_links = []
    
    # Try to find all the links in the param
    (1..8).each do |num|
      
      name_key = "name_link" + num.to_s
      url_key = "url_link" + num.to_s
      id_key = "id_link" + num.to_s
      
      name = params[name_key.to_sym]
      url = params[url_key.to_sym]
      id = params[id_key.to_sym]
      
      # Don't add it's empty
      next if name.nil? or name.empty? or name.nil? or url.empty?
      
      if !id.nil? and !id.empty?
        link = Link.find(id)
        link.guess_link(url, name)
      else
        # Create a new link
        link = Link.new
        link.guess_link(url, name)
      end

      new_links << link
    end
    
    return new_links
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
      logger.info "Admin saved a venue: #{@venue.id}"
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
