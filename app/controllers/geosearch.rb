# To be included by controllers that need to do ferret geo-searches
module Geosearch
  include Ferret::Search
  
  # To be called via ajax so the session state is always up to date
  def set_location_radius
    @session[:location] = params[:location].strip
    @session[:radius] = params[:radius].strip
  end
  
  def toggle_only_local
    @session[only_local_session_key(params[:type])] = params[:checked]
  end
  
  protected
  
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
  
  def popularity_sort_field
    SortField.new("popularity", {:sort_type => SortField::SortType::INTEGER, :reverse => true})
  end
  
  def prepare_query(type, location = nil, radius = nil, always_local = false)
    query = params[:query].nil? ? "" : params[:query].strip
    
    return query, nil, nil, nil if @session[only_local_session_key(type)] == 'false' and !always_local
    
    radius = radius || @session[:radius]
    if radius != "" and radius.to_f <= 0
      flash[:error] = "The search radius must be a positive number"
      return nil
    end
    
    lat = long = nil
    loc = location || @session[:location]
    
    if not loc.nil? and loc != ""
      begin 
        zip = Address::parse_city_state_zip(loc.strip)
      rescue Exception => e
        flash[:error] = e.to_s
        return nil
      end
      
      lat = zip.latitude
      long = zip.longitude
    end
    
    return query, radius, lat, long
  end
  
end