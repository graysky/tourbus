class ShowController < ApplicationController
  layout "public"
  
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
  
end
