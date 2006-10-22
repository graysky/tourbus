# Allows a client to get a single url to work on
class GetWorkServlet < BaseServlet

  def handle_request(req, resp)
    worker = get_worker(req)
    
    # Hand out one url at a time
    site = SongSite.next_crawlable_site(worker)
    if site.nil?
      error(resp, ERROR_NO_WORK, "No available sites to crawl")
      return
    end 
    
    xml = "<site><url>#{cdata(site.url)}</url><id>#{site.id}</id></site>"
    success(resp, xml)
  end
end

class RenewWorkServlet < BaseServlet
  def handle_request(req, resp)
    worker = get_worker(req)
    site = get_site(req, worker)
    
    if site.renew(worker)
      success(resp, '')
    else
      error(resp, ERROR_CANT_RENEW)
    end
  end
end

class FinishCrawlServlet < BaseServlet

  def handle_request(req, resp)
    worker = get_worker(req)
    site = get_site(req, worker)
    
    error = req.query["error"] == "true"
    comment = req.query["comment"]
    count = req.query["count"].to_i
    
    get_site(req).finish_crawl(worker, error, comment, count)
    success(resp, '')
  end
end

class AddSongsServlet < BaseServlet

  def handle_request(req, resp)
    worker = get_worker(req)
    site = get_site(req, worker)
    
    req.body_doc.root.each_element("//request/songs/song") do |elem|
      song = {}
      elem.elements.each do |child|
        song[child.name] = child.text
      end
      
      if song['artist'] && song['artist'] != ''
        Song.from_hash(song, site)
      end
    end
    
    success(resp, '')
  end
  
end