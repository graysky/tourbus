module FindHelper
  def search_results_suffix(type)
    return " (nationwide)" if @session[only_local_session_key(type)] == 'false'
    return " (near #{session[:location]})"
  end
end
