require 'net/http'
require 'uri'
require 'uuidtools'
require 'yaml'

class TurkersController < ApplicationController

  def hit
    begin
      @site = TurkSite.find(params[:turk_site_id])
    rescue
      flash.now[:error] = "We're sorry, this seems to be an invalid hit. Please <a href='mailto:feedback@tourb.us'>contact us</a> " +
                      " and we will get to the bottom of it."
      render :partial => "hit_error", :layout => "turk_hit"
      return
    end

    if @site.last_approved_hit
      # This is an update hit. Load up the previous params.
      @is_update = true
      @prev_shows = []
      submission = @site.last_approved_hit.turk_hit_submission
      submission.params.each do |k, v| 
        if k.starts_with?("date_") && !v.blank?
          @prev_shows << k.split("_")[1].to_i
        end
      end
      
      puts @prev_shows      
    else
      @is_update = false
    end
  
    if request.get?
      # We must be showing the form
      if @is_update
        submission.params.each do |k, v| 
          params[k] = v
        end
      else
        params["date_0"] = 'DD/MM/YYYY'
      end
      
      render :layout => "turk_hit"
      return
    end
    
    # do some validation on the form post
    @errors = []
    @invalid_bands = []
    show_count = 0
    parser = ShowParser.new(nil)
    
    for i in (0...TurkHitSubmission::MAX_SHOWS)
      date = params["date_#{i}"]
      bands = params["bands_#{i}"]
      
      if (date.blank? && bands.blank?)
        next
      end
      
      if (d = DateUtils.parse_date_loosely(date)).nil?
        @errors << [i, "Invalid date: #{date}. The expected format is MM/DD/YY"]
        next
      end
      
      tickets = params["tickets_#{i}"]
      if !tickets.blank? && !tickets.downcase.starts_with?("http://")
        @errors << [i, "Invalid ticket link : \"#{tickets}\". Must start with http://"]
        next
      end
      
      if @is_update && !@prev_shows.include?(i)
        params["from_update_#{i}"] = true
      else
        params["from_update_#{i}"] = false
      end
      
      bands = params["bands_#{i}"].to_s.gsub(/\r/, '').split(/\n/)
      index = 0
      bands_this_show = []
      for band in bands
        b = parser.probable_band(band, index, nil)
        if b
          bands_this_show << b
        else
          @invalid_bands << [i, band]
        end
        
        index += 1
      end
       
      if bands_this_show.empty?
        @errors << [i, "No valid band names found"]
      end
       
      show_count += 1
    end
    
    if show_count == 0
      @errors << [nil, "We did not find any valid shows. Did you hit submit by accident?"]
    elsif show_count.to_i < @site.min_shows.to_i
      @errors << [nil, "It looks like you missed a few shows. Please go back and make sure you added all of the show listings on the page. " + 
                       "If you're sure you got them all, submit the HIT with a short explanation instead of a code and we will accept the HIT if you're right."]
    elsif (@invalid_bands.size / show_count.to_f) < 0.4
      # We can tolerate some errors
      @invalid_bands = []
    end
    
    if @errors.size > 0 || @invalid_bands.size > 0
      logger.info("Errors submitting form")
    else
      # Success! Give this submission a token and report that back to the worker
      @sub = TurkHitSubmission.new
      @sub.token = UUID.random_create.to_s
      @sub.params = params
      @sub.turk_site_id = @site.id
      
      if (!@sub.save)
        @errors << [nil, "There was an error saving your submission. Please try again."]
      else
        # Forward on to the thank you screen
        render :partial => "hit_success", :layout => "turk_hit"
        return
      end
      
    end
    
    render :layout => "turk_hit"
  end
  
end