require_dependency 'favorites_calculator'
require_dependency 'badge'
require_dependency 'ical'

# The public page for a Fan
class FanPublicController < ApplicationController
  include Badge
  include Ical
  before_filter :find_fan, :except => :no_such_fan
  helper :show
  helper :portlet
  helper :band
  helper :map
  helper :tag
  helper :photo
  helper :feed
  helper :comment
  upload_status_for :change_logo
  session :off, :only => [:rss, :friends_shows_rss, :ical, :badge, :js ]
  layout "public", :except => [:rss, :friends_shows_rss, :ical, :badge, :js ] 
  
  # Show the main fan page
  def index
    
    @shows = @fan.shows.find(:all, :conditions => ["date > ?", Time.now - 2.days], :limit => 7)
    @bands = @fan.bands.random(5)
    
    if @logged_in_as_fan and @session[:first_login] and @fan.last_login > 8.hours.ago
      flash.now[:info] = render_to_string :action => 'intro_msg', :layout => false
    end
    
    # Record the page view
    inc_page_views(@fan)
  end
  
  def shows
    @shows = @fan.shows.find(:all, :conditions => ["date > ?", Time.now - 2.days])
  end
  
  def all_shows
    @shows = @fan.shows.find(:all)
  end
  
  def favorite_bands
    @bands = @fan.bands.find(:all)
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
  
  def set_bio
    @fan.bio = sanitize_text_for_display(params[:value])
    @fan.save
    render :text => @fan.bio
  end
  
  
  def photo
    render_component :controller => "photo", :action => "show_one", 
                     :params => {"photo_id" => params[:photo_id], 
                                 "name" => @fan.name, 
                                 "showing_creator" => false}
  end
  
  # Create an image badge for the fan to put on MySpace/blog/etc.
  def badge
    key = {:action => 'badge', :part => 'fan_badge'}
  
    when_not_cached(key, 20.hours.from_now) do
      # Cache the creation of a new badge
      shows = @fan.shows.find(:all, :conditions => ["date > ?", Time.now - 2.days], :limit => 3)
      create_image_badge(@fan, shows)
      
      # This is a hack to write to the fragment
      write_fragment(key, "fake-content")  
    end

    send_badge(get_image_badge(@fan))
  end
  
  def invite
    return if @request.get?
    return if @fan.nil?
    
    emails = params[:emails]
    emails.chomp!(" ")
    
    # Try to format emails correctly
    to_addrs = emails.gsub(/,/,' ').split(' ')
    
    from_name = params[:from]
    msg = params[:msg]
      
    # Send the email
    msg = ShareMailer.do_invite_friend(to_addrs, from_name, @fan, msg)
    if msg.nil?
      SystemEvent.info("#{from_name} (id = #{@fan.id}) invited friends", SystemEvent::SHARING, to_addrs.join(","))
      render :nothing => true
    elsif
      # There was an error sending
      render :text => msg
    end
  end
  
  # Javascript for badge
  def js
    
    num = params['n'] || 5 # Default to 5 shows
    
    key = {:action => 'js', :part => "fan_js_#{num}"}

    when_not_cached(key, 4.hours.from_now) do
      # Get the shows to display only when cache is cold
      @shows = @fan.upcoming_shows.first(num.to_i)
    end
    
    # Get the contents for the badge  
    badge = get_html_badge(@fan, @shows, key)
    render :text => badge
  end
  
  # RSS feed for the fan
  def rss
    # Set the right content type
    @headers["Content-Type"] = "application/xml; charset=utf-8"
    
    # Check how they want it sorted
    sort_by = params['sort'] || :added
        
    key = {:action => 'rss', :part => "fan_feed_#{sort_by.to_s}"}

    when_not_cached(key, 120.minutes.from_now) do
      # Fetch and cache the RSS items
      get_rss_items(sort_by.to_sym)
    end
    
    # The external URL to this fan
    base_url = public_fan_url(@fan)
    
    render(:partial => "shared/rss_feed", 
      :locals => { :obj => @fan, :base_url => base_url, :key => key, :items => @items, :title => "#{@fan.name}" })
  end
  
  # An iCal feed
  # http://en.wikipedia.org/wiki/RFC2445_Syntax_Reference
  # http://en.wikipedia.org/wiki/ICalendar
  def ical
    key = {:action => 'ical', :part => 'fan_feed'}
    cal_string = ""

    when_not_cached(key, 3.hours.from_now) do
      # Fetch and cache the iCal items
      get_ical_items
      cal_string = get_ical(@shows, @fan.name)
      write_fragment(key, cal_string)  
    end
    
    ical_feed = read_fragment(key) || cal_string
    render :text => ical_feed
  end
  
  def friends_shows_rss
    # Set the right content type
    @headers["Content-Type"] = "application/xml; charset=utf-8"
    
    key = {:action => 'rss', :part => 'fan_friends_feed'}

    when_not_cached(key, 90.minutes.from_now) do
      # Fetch and cache the RSS items
      @items = @fan.friends_shows
    end
    
    # The external URL to this fan
    base_url = public_fan_url(@fan)
    
    render(:partial => "shared/rss_feed", 
      :locals => { :obj => @fan, :base_url => base_url, :key => key, :items => @items, :title => "#{@fan.name}'s Friends' Shows" })
  end
  
  private
  
  # Make queries to get the items for iCal feed
  def get_ical_items
    # Include upcoming shows they are attending and watching
    @shows = @fan.shows.find(:all, :conditions => ["date > ?", Time.now])
  end
  
  # Make queries to get the items for RSS feed
  # sort_by => :added (default: when show was added)
  #            :show (order by show dates)
  def get_rss_items(sort_by)
    # Default, sort by the date the show was added  
    sort_by_date_added = true
    
    # Optionally sort by show date
    sort_by_date_added = false if sort_by == :show
    
    # Include upcoming shows they are attending and watching
    shows = @fan.shows.find(:all, :conditions => ["date > ?", Time.now])
    
    # Include favories that have 
    updated_since = Time.now - 2.weeks
    
    faves = FavoritesCalculator.new(@fan, updated_since)
    
    new_fave_shows = faves.new_shows
    
    # Items for the feed and remove dups
    @items = shows | new_fave_shows

    # Sort the items by when they were created with the most
    # recent item first in the list
    @items.sort! do |x,y| 
      # Sort the items using either date added or show date
      if sort_by_date_added
        y.created_on <=> x.created_on
      else
        x.date <=> y.date
      end
    end
    
  end
  
  def no_such_fan
  end

  def find_fan
    @fan = Fan.find_by_name(params[:fan_name])
    if @fan.nil?
      render :action => 'no_such_fan', :status => "404 Not Found"
      return false
    end
    
   if logged_in_fan
    @logged_in_as_fan = (logged_in_fan.id == @fan.id)
   end
   
   @fan
  end
end
