# To be included by controllers that need to do ferret geo-searches
module Geosearch
  include Ferret::Search
  
  # To be called via ajax so the session state is always up to date
  def set_location_radius
    do_set_location_radius
    render :nothing => true
  end
   
  def toggle_only_local(only_local = nil)
    do_toggle_only_local(only_local)
    render :nothing => true
  end
  
  protected
  
  def do_set_location_radius
    if params[:location].nil?
      @session[:location] = ''
    else
      @session[:location] = params[:location].strip
    end
    
    if params[:radius].nil?
      # Set default if they didn't enter a radius
      @session[:radius] = Address::DEFAULT_RADIUS
    else
      @session[:radius] = params[:radius].strip
    end
  end
  
  def do_toggle_only_local(only_local = nil)
    @session[only_local_session_key(params[:type])] = only_local.nil? ? params[:checked] : only_local
  end
  
  # Set some default location params if we are not logged in
  def check_location_defaults
    return if logged_in_fan or @session[:location]
    
    # TODO Could attempt to figure out the users location
    set_location_defaults('', '', 'false', 'false', 'false')
  end
  
  # A bit of a hack, but create the session key to use with the type name
  def only_local_session_key(type)
    "only_local_#{type}".to_sym
  end
  
  def created_on_sort_field
    SortField.new("created_on", {:sort_type => SortField::SortType::INTEGER, :reverse => true})
  end
  
  def date_sort_field
    SortField.new("date", {:sort_type => SortField::SortType::INTEGER, :reverse => false})
  end
  
  def popularity_sort_field
    SortField.new("popularity", {:sort_type => SortField::SortType::INTEGER, :reverse => true})
  end
  
  def name_sort_field
    SortField.new("sort_name", {:sort_type => SortField::SortType::STRING, :reverse => false})
  end
  
  def prepare_query(type, location = nil, radius = nil, always_local = false)
    query = params[:query].nil? ? "" : params[:query].strip
   
    if params[:only_local] and params[:only_local].strip != ''
      params[:type] = type
      do_toggle_only_local(params[:only_local])
    end
    
    return query, nil, nil, nil if @session[only_local_session_key(type)] == 'false' and !always_local
    
    radius = radius || @session[:radius] || Address::DEFAULT_RADIUS
    if radius != "" and radius.to_f <= 0
      flash[:error] = "The search radius must be a positive number"
      logger.error("Bad search radius: #{radius}")
      return nil
    end
    
    lat = long = nil
    loc = location || @session[:location]
    
    if not loc.nil? and loc != ""
      begin 
        zip = Address::parse_city_state_zip(loc.strip)
      rescue Exception => e
        flash[:error] = "Sorry, we couldn't find your location."
        return nil
      end
      
      lat = zip.latitude
      long = zip.longitude
    end
    
    return query, radius, lat, long
  end
  
end