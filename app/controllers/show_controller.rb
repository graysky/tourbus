require_dependency "show_creator"
require_dependency 'ical'

# Handles create/edit/viewing Shows
class ShowController < ApplicationController
  include ShowCreator
  include Geosearch
  include Ical   
  helper :map
  helper :tag
  helper :comment
  helper :photo
  helper :feed
  helper :portlet
  
  session :off, :only => [:rss, :ical]
  before_filter :find_show, :except => [ :venue_search, :add ]
  before_filter :some_login_required, :only => [:add]
  
  layout "public", :except => [:rss, :ical ] 
  
  # Show a specific show. (Perhaps this is a bad name for this action?)
  def show
    # Record the page view
    inc_page_views(@show)
  end
  
  def add
    # TODO Among other things error handling
    
    if @request.get?
      prepare_new_show
    else
      result = create_edit_show(true)
      return if !result
      
      flash[:success] = 'Show added'
      redirect_to_url "/show/#{@show.id}"
    end
  end
  
  def edit
    if @request.get?
      create_bands_playing_content(@show.bands)
      params[:selected_venue_name] = @show.venue.name
      params[:selected_venue_id] = @show.venue.id
      flash.now[:info] = "Thanks for helping us make this listing more accurate. If you can't fix the problem" +
                         " using this form please click the \"Report a Problem\" link on the previous page."
    else
      return if not create_edit_show(false)
      flash[:success] = 'Show edited'
      redirect_to_url "/show/#{@show.id}"
    end 
  end
  
  
  # TODO FIXME - Can't use "@show.name" because the show's ID wans't passed in
  def photo
    render_component :controller => "photo", :action => "show_one", 
                     :params => {"photo_id" => params[:photo_id], "name" => @show.name}
  end
  
  # Search for a venue as part of adding a show
  def venue_search
    name = params[:venue_search_term]
    name = params[:name] if name.nil? || name == ""
 
    if name && name != ""
      params[:query] = name.strip + '*'
      query, radius, lat, long = prepare_query(Venue.table_name, params[:location], params[:radius], true)
      if query.nil?
        @results = []
        count = 0
      else
        begin
          @results, count = Venue.ferret_search_date_location(query, nil, lat, long, radius, default_search_options)
          paginate_search_results(count)
        rescue
          @results = []
          count = 0
        end
      end
    else
      @results = []
      count = 0
    end
    
    render(:partial => "shared/venue_results")
  end
  
  # RSS feed for the show
  def rss
    # Set the right content type
    @headers["Content-Type"] = "application/xml; charset=utf-8"

    key = {:action => 'rss', :part => 'show_feed'}

    when_not_cached(key, 15.minutes.from_now) do
      # Fetch and cache the RSS items
      get_rss_items
    end

    # The external URL to this venue
    base_url = public_show_url(@show)
    
    render(:partial => "shared/rss_feed", 
      :locals => { :obj => @show, :base_url => base_url, :key => key, :items => @items, :title => "#{@show.name}"  })
  end
  
  def fans
  end
  
  # Share this show with a friend
  def share
    return if @request.get?
    
    emails = params[:emails]
    
    emails.chomp!(" ")
    
    # Try to format emails correctly
    to_addrs = emails.gsub(/,/,' ').split(' ')
    
    from_name = params[:from]
    msg = params[:msg]
      
    # Send the email
    msg = ShareMailer.do_share_show(to_addrs, from_name, @show, msg)
    if msg.nil?
      render :nothing => true
      SystemEvent.info("#{from_name} shared show #{@show.id} with friends", SystemEvent::SHARING, to_addrs.join(",")) 
    elsif
      render :text => msg
    end
  end
  
  # An iCal feed
  # http://en.wikipedia.org/wiki/RFC2445_Syntax_Reference
  # http://en.wikipedia.org/wiki/ICalendar
  def ical
    key = {:action => 'ical', :part => 'show_feed'}
    cal_string = ""

    when_not_cached(key, 5.hours.from_now) do
      # Fetch and cache the iCal items
      shows = [@show]
      cal_string = get_ical(shows, @show.name)
      write_fragment(key, cal_string)  
    end
    
    ical_feed = read_fragment(key) || cal_string
    render :text => ical_feed
  end
  
  private
  
  # Make queries to get the items for RSS feed
  def get_rss_items
    comments = @show.comments.find(:all,
                                   :order => "created_on DESC",
                                   :limit => 20
                                   ) 

    photos = @show.photos.find(:all,
                               :order => "created_on DESC",
                               :limit => 10
                               ) 

    # Items for the feed
    @items = []

    comments.each { |x| @items << x }
    photos.each { |x| @items << x }
    
    # Add the show itself to the feed
    @items << @show
    
    # Sort the items by when they were created with the most
    # recent item first in the list
    @items.sort! do |x,y| 
      # Maybe test if x & y respond_to?(created_on)
      # Right now, we just assume it
      y.created_on <=> x.created_on
    end
  end
  
  def create_edit_show(new)
    begin
      create_new_show_and_venue(new)
    rescue Exception => e
      logger.error("Error creating show:\n#{e.backtrace}")
      params[:error] = e.to_s
      create_bands_playing_content
      return false
    end
    
    begin
      Band.transaction(*@bands_playing) do
        Show.transaction(@show) do
          
          if new
            @show.created_by_band = logged_in_band if logged_in_band
            @show.created_by_fan = logged_in_fan if logged_in_fan
          elsif logged_in_fan
            @show.edited_by_fan = logged_in_fan
          elsif logged_in_band
            @show.edited_by_band = logged_in_band
          end
          
          add_bands 
         
          @show.venue.num_upcoming_shows += 1
          if !@show.save || !@show.venue.save
            logger.warn(@show.inspect)
            create_bands_playing_content
            return
          end
        end
        
      end
    rescue Exception => ex
      logger.error(ex.to_s)
      params[:error] = ex.to_s
      create_bands_playing_content
      return false
    end
    
    @show.ferret_save
    return true
  end
  
  def no_such_show
  end
  
  # Find the show from the ID param
  def find_show
    # Look up the show
    @show = Show.find_by_id(params[:id])
    
    if @show.nil?
      # Could not find the show
      render :action => 'no_such_show', :status => "404 Not Found"
      return false
    end
  end
  
  def some_login_required
    return true if logged_in?
    
    # Not logged in... TODO handle this better
    redirect_to :controller => "login"
    return false
  end
  
end
