class FindController < ApplicationController
  layout "public"
  helper :show
  
  def band
    return if request.get? and params[:query].nil?
    
    query = params[:query].strip
    @results, count = Band.ferret_search(query, default_search_options)
    paginate_search_results(count)
  end

  def venue
    return if request.get?
  end

  def show
    return if request.get? and params[:query].nil?
    
    query = params[:query].strip
    @results, count = Show.ferret_search_date_location(query, Time.now, nil, nil, nil, default_search_options)
    paginate_search_results(count)
  end
  
  protected
  
  # Returns a rails paginator
  def paginate_search_results(count)
    @pages = Paginator.new(self, count, PAGE_SIZE, @params['page'])
  end
  
  # Takes into account paging
  def default_search_options
    options = {}
    options[:num_docs] = PAGE_SIZE
    if params['page']
      options[:first_doc] = (params['page'].to_i - 1) * PAGE_SIZE
    end
    
    return options
  end
  
  private
  
  PAGE_SIZE = 10
end
