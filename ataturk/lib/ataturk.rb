# Creates new mturk HITs
class Ataturk
  attr :debug
  attr :turk
  
  def initialize(debug = false, turk = TurkApi.new)
    @debug = debug
    @turk = turk
    @logger = TURK_LOGGER
  end
  
  # Create hits for the day's sites.
  def create_hits
    @logger.info "Creating HITs..."
    
    sites = TurkSite.find_all_by_group(Date.today.wday)
    
    if @debug
      # just choose one
      sites = [TurkSite.find(:first)]
    end
    
    for site in sites
      if site.is_hit_due? || @debug
        # Create a HIT for this site
        @logger.info "Creating hit for site #{site.id}, #{site.url}"
        price_adj = (hit.purpose == TurkHit::PURPOSE_COMPLETE ? 2 : 1)
        hit_id = @turk.create_hit(site)
        raise "nil returned from create_hit!" if hit_id.nil?
        
        begin
          site.add_hit(hit_id)
        rescue Exception => e
          @logger.info "  Disabling hit after error..."
          @turk.disable_hit(hit_id)
          raise e
        end
      end
    end
    
  end
  
  # Process all the reviewable hits
  def process_hits(dummy_token = nil)
    @logger.info("Processing HITs...")
    hit_ids = @turk.get_reviewable_hits
    
    anansi = AnansiImporter.new
    
    for id in hit_ids
      a = @turk.get_hit_assignment(id, dummy_token)
      
      worker = TurkWorker.find_by_aws_worker_id(a.worker_id) 
      if worker.nil?
        worker = TurkWorker.new(:aws_worker_id => a.worker_id)
        worker.save!
      end
      
      shows = get_shows(a)
      prepared_shows = shows.map { |show| anansi.prepare_show(show) }
      write_shows(prepared_shows, id)    
      puts id
      hit = TurkHit.find_by_aws_hit_id(id)
      hit.set_reviewing(a)
      
    end
  end
  
  def approve_reviewed_hits
    hits = TurkHit.find_all_by_status(TurkHit::STATUS_REVIEWING)
    hits.each do |hit|
      approve_hit(hit)
    end
  end
  
  # Approve the given HIT and pay the worker
  def approve_hit(hit, feedback = nil)
    TurkHit.transaction do
      hit.set_approved
      @turk.approve_assignment(hit.aws_assignment_id, feedback)
      @turk.dispose_hit(hit.aws_hit_id)
    end
  end
  
  # Reject a hit. If extend=true, extend the hit (allow other workers to pick it up)
  def reject_hit(hit, extend, feedback = nil)
    TurkHit.transaction do
      hit.set_rejected
      FileUtils.rm_f(File.join(AnansiImporter::ATATURK_DIR, AnansiImporter.ataturk_file_name(hit.aws_hit_id)))
      @turk.reject_assignment(hit.aws_assignment_id, feedback)
      
      if extend
        @turk.extend_hit 
      else
        @turk.dispose_hit(hit.aws_hit_id)
      end
    end
  end
  
  ####################
  # Helpers
  ####################
  protected
  
  # Get the YAML for the shows contained in a completed assignment.
  # We assume that the params have already been validated.
  def get_shows(assignment)
    submission = TurkHitSubmission.find_by_token(assignment.answer)
    params = submission.params
    
    shows = []
    site_visit = SiteVisit.ataturk_site
    parser = ShowParser.new(nil)
    
    for i in (0...TurkHitSubmission::MAX_SHOWS)
      date = params["date_#{i}"]
      bands = params["bands_#{i}"]
      
      if (date.blank? || bands.blank?)
        next
      end
      
      @logger.info "Show: #{date} at #{submission.turk_site.venue.name}..."
      
      show = {}
      shows << show
      show[:ataturk] = true
      show[:venue] = { :id => submission.turk_site.venue_id }
      show[:bands] = []
      show[:site] = site_visit.name + ": #{submission.turk_site.url}"
      show[:site_visit_id] = site_visit.id
      show[:date] = DateUtils.parse_date_loosely(date)
      show[:worker] = assignment.worker_id
      show[:hit_id] = assignment.hit_id
      show[:cost] = params["cost_#{i}"]
      show[:time] = parser.parse_as_time(params["time_#{i}"], false)
      show[:soldout] = true if params["soldout_#{i}"]
      show[:cancelled] = true if params["cancelled_#{i}"]
      show[:source_link] = submission.turk_site.resolved_url
      
      tickets = params["tickets_#{i}"]
      show[:ticket_link] = tickets if tickets && tickets != ""
      
      bands = params["bands_#{i}"].to_s.gsub(/\r/, '').split(/\n/)
      index = 0
      for band in bands
        b = parser.probable_band(band, index, nil)
        show[:bands] << b if b
      end     
    end
    
    return shows
  end
  
  # Write a yaml file for the shows
  def write_shows(shows, hit_id)
    FileUtils.mkdir_p(AnansiImporter::ATATURK_DIR) if not File.exists?(AnansiImporter::ATATURK_DIR)
    yml_file = File.new(File.join(AnansiImporter::ATATURK_DIR, AnansiImporter.ataturk_file_name(hit_id)), "w")
    
    str = ""
    for show in shows
      str << show.to_yaml
      str << "\n\n"
    end

    yml_file.write(str)
    yml_file.close
  end
  
end