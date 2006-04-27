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
    
    when_not_cached(bands_key, 3.hours.from_now) do
      # Fetch and cache the list of bands
      get_popular_bands
    end
    
    when_not_cached(shows_key, 4.hours.from_now) do
      # Fetch and cache the list of shows
      get_popular_shows
    end
    
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
    
    @shows, count = Show.ferret_search_date_location('*', Time.now, lat, long, @session[:radius] || 50, options)
    @shows.sort! { |x,y| x.date <=> y.date }
    
    if @shows.size == 0 and local_popular_shows? and !force_national
      # If we searched locally, and there weren't any shows
      # then show them the national results instead
      return get_popular_shows(true)
    end
  end 
  
  def get_popular_bands
    # The 10 most popular bands
    options = default_search_options
    options[:sort] = popularity_sort_field
    
    @bands, count = Band.ferret_search_date_location('*', nil, nil, nil, nil, options)
  end  
end