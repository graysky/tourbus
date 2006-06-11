# Shows the basic public pages of the site
class PublicController < ApplicationController
  include Geosearch
  
  helper :portlet
  helper_method :local_popular_shows?
  helper_method :get_popular_shows_cache_key
  
  before_filter :announcement, :only => :front_page
  layout "public", :except => [:beta, :beta_signup] 

  # The front page of the app
  def front_page
    # Note: this needs to match the view exactly
    bands_key = {:action => 'front_page', :part => 'popular_bands'}
    shows_key = {:action => 'front_page', :part => get_popular_shows_cache_key}
    
    when_not_cached(bands_key, 14.hours.from_now) do
      # Fetch and cache the list of bands
      get_popular_bands
    end
    
    when_not_cached(shows_key, 4.hours.from_now) do
      # Fetch and cache the list of shows
      get_popular_shows
    end
  end
  
  def dispatch_fcgi
    redirect_to :action => "front_page"
  end
  
  # Allow pre-defined shortcuts
  def metro
    metro = params['metro'] || ""
    metro.downcase!
    
    case metro
    # New metros need to be added here and in routes for subdomain
    when "boston" then set_metro("Boston, MA")
    when "austin" then set_metro("Austin, TX")   
    when "seattle" then set_metro("Seattle, WA")
    when "chicago" then set_metro("Chicago, IL")
    when "sanfran" then set_metro("San Francisco, CA")
    when "sf" then set_metro("San Francisco, CA")
    else
      # Invalid metro set    
    end
    
    # Show the normal front page with location set
    front_page
    render :action => "front_page"
  end
  
  # Sub-domain shortcuts for metros, ex. "boston.tourb.us"
  def boston
    metro_redirect("boston")
  end
  
  def austin
    metro_redirect("austin")
  end
  
  def seattle
    metro_redirect("seattle")
  end
  
  def chicago
    metro_redirect("chicago")
  end
  
  def sanfran
    metro_redirect("sanfran")
  end
  
  # The beta page to ask for invitation code
  def beta
    return if @request.get?
    
    # Check the form
    invite_code = params['code']
    
    # This needs to match what application has
    secret = "backstage"
    
    # Check to see if they should be allowed in
    if invite_code == secret
      # Let them in and remember they got in!
      cookies[:invite] = { :value => secret, :expires => Time.now + 6.months }
    
      # Redirect to front page
      redirect_to("/")
    else
      flash.now[:error] = "Invalid invitation code -- please try again"
    end
    
  end
  
  # Form to sign up for the beta
  def beta_signup
    return if @request.get?  
  
    email_addr = params['email']
    
    # Send us mail about the signup
    BetaMailer.deliver_signup(email_addr)
  end
  
  def tour
  end
  
  # The News page
  def news
    # TODO Need to paginate
    @announcements = Announcement.find(:all, :order => "created_at DESC")
  end
  
  # The FAQ page
  def faq
  end
  
  private
  
  def page_size
    10
  end
  
  # Form a key to cache the list of upcoming shows
  def get_popular_shows_cache_key
    
    if local_popular_shows?
      loc = String.new(@session[:location])
      
      loc.gsub!(/,/, '_') # Replace comma
      loc.gsub!(/\s*/, '') # Replace whitespace
      loc.downcase!
      
      # Will be like: 'boston_ma_50'
      key = loc + "_" + @session[:radius].to_s
    else
      # Default key for national searching    
      key = "natl_upcoming_shows"
    end
    
    return key
  end
  
  # Need to specify full URL to clear the subdomain on redirect
  def metro_redirect(metro)
    redirect_to "http://tourb.us/metro/#{metro}"
  end
  
  # Set a default location + radius for this metro IF there isn't one already set.
  # Assumes caller sets a valid location, like "Boston, MA"
  def set_metro(location)
    @session[:location] = location
    @session[:radius] = 50
  end
  
  def local_popular_shows?
    @session[:location] and @session[:location] != ''
  end
    
  def get_popular_shows(force_national = false)
    # Get the 10 most popular shows, then sort by date
    options = default_search_options
    options[:sort] = popularity_sort_field
    
    if local_popular_shows? and !force_national
      begin
        zip = Address::parse_city_state_zip(session[:location])
        lat = zip.latitude
        long = zip.longitude
      rescue
        lat = long = nil
      end
    end
    
    @shows, count = Show.ferret_search_date_location('*', Time.now, lat, long, @session[:radius] || Address::DEFAULT_RADIUS, options)
    @shows.sort! { |x,y| x.date <=> y.date }
    
    if @shows.size == 0 and local_popular_shows? and !force_national
      # If we searched locally, and there weren't any shows
      # then show them the national results instead
      return get_popular_shows(true)
    end
  end 

  # The 10 most popular bands that have > 0 upcoming show
  def get_popular_bands
    
    # Use brute force to make sure we get 10 bands with upcoming
    # shows. We cache this value so it being inefficent shouldn't 
    # be a perf. problem.
    num_bands = 10
    
    # Query most 200 popular bands first
    bands_with_shows = get_bands(num_bands, 200)
    
    if bands_with_shows.size < num_bands
      # We didn't get enough bands, try again with more bands
      bands_with_shows = get_bands(num_bands, 400)
    end
    
    @bands = bands_with_shows
  end
  
  # Attempt to get the most popular bands from ferret with >= 1 upcoming show
  # num_docs => how many to fetch from ferret
  def get_bands(num_bands, num_docs)  
    options = default_search_options
    options[:sort] = popularity_sort_field
    
    options[:num_docs] = num_docs
    
    bands_with_shows = []
    pop_bands, count = Band.ferret_search_date_location('*', nil, nil, nil, nil, options)
    
    # Only store bands with > 0 upcoming shows
    pop_bands.each do |b|
      bands_with_shows << b if b.num_upcoming_shows > 0      
      break if bands_with_shows.size >= num_bands
    end
    
    return bands_with_shows 
  end
end