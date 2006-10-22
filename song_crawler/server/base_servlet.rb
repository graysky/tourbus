require 'webrick'
require "rexml/document"

class BaseServlet < WEBrick::HTTPServlet::AbstractServlet
  include REXML
  include SongCrawlerBase
  
  ALLOWED_HOSTS = []
  
  # Extend the request object to store the parsed xml doc of posted requests
  class WEBrick::HTTPRequest
    attr_accessor :body_doc
  end
  
  def do_GET(req, resp)
    resp['content-type'] = 'text/xml'
    
    # Check allowed hosts
    
    # Parse request body for posts
    begin
      if req.request_method == "POST"
        req.body_doc = Document.new(req.body)
        
        worker = req.body_doc.get_text("request/worker")
        req.query["worker"] = worker.value if worker
        
        site = req.body_doc.get_text("request/site")
        req.query["site"] = site.value if site
      end
    rescue Exception => e
      error(resp, ERROR_UNKNOWN, "Invalid XML: #{e}")
      return
    end
    
    # Check that we have a worker id
    worker = get_worker(req)
    if worker.nil? || worker == ""
      error(resp, ERROR_INVALID_WORKER, "Invalid worker id")
      return
    end
    
    begin
      handle_request(req, resp)
    rescue Exception => e
      error(resp, ERROR_UNKNOWN, e.to_s)
    end
  end
  
  alias do_POST do_GET
  
  # Send back a well-formatted successful response
  def success(resp, body)
    resp.body = "<success>#{body}</success>"
    resp.status = 200
  end
  
  # Write back an xml document with an error
  def error(resp, code, msg = '', http_status = 200)
    @logger.error("#{code}: #{msg}") if code != ERROR_NO_WORK
    resp.body = "<error><code>#{code}</code><msg>#{cdata(msg)}</msg></error>"
    resp.status = http_status
  end
  
  def get_worker(req)
    req.query["worker"]
  end
  
  def get_site(req, worker = nil)
    begin
      site = SongSite.find(req.query["site"].to_i)
    rescue 
      raise "Invalid site id: #{req.query['site']}"
    end
    
    raise "#{worker} did not initiate crawl" if site && worker && site.crawl_worker != worker
    site
  end
end