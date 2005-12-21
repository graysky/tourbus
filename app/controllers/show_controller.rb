class ShowController < ApplicationController
  include ShowCreator
    
  helper :map
  helper :tag
  helper :comment
  helper :photo
  
  before_filter :find_show, :except => [ :venue_search ]
  layout "public"
  
  # Show a specific show. (Perhaps this is a bad name for this action?)
  def show
  
  end
  
  # TODO FIXME - Can't use "@show.name" because the show's ID wans't passed in
  def photo
    render_component :controller => "photo", :action => "show_one", 
                     :params => {"photo_id" => params[:photo_id], "name" => @show.name}
  end
  
  # Search for a venue as part of adding a show
  def venue_search
    begin
      name = params[:venue_search_term]
      @venue = Venue.new(params[:venue])
      conditions = venue_location_conditions
         
      if !name.nil? && name != ""
        conditions = ["#{conditions} and name like ?", "%#{name}%"]
      end
      
      @venue_pages, @venues = paginate :venues, 
                                       :conditions => conditions, 
                                       :order_by => "name DESC", 
                                       :per_page => 20
      
      if (@venue_pages.item_count == 0)
        params[:error_message] = "No results found"
      end
    rescue Exception => ex
      params[:error_message] = ex.to_s
    end
    
    render(:partial => "shared/venue_results")
  end
  
  private
  
  # Find the show from the ID param
  def find_show
    # Look up the show
    @show = Show.find_by_id(params[:id])
    
  end
  
end
