require 'net/http'
require 'uri'

class TurkersController < ApplicationController

  def hit
    begin
      @site = TurkSite.find(params[:turk_site_id])
    rescue
      flash.now[:error] = "We're sorry, this seems to be an invalid hit. Please <a href='mailto:gm@tourb.us'>contact us</a> " +
                      " and we will get to the bottom of it."
      render :partial => "hit_error", :layout => "turk_hit"
      return
    end
    
    @assignmentId = params[:assignmentId]  
    if "ASSIGNMENT_ID_NOT_AVAILABLE" == @assignmentId
      @preview = true
    end
       
    if request.get?
      # We must be showing the form
      params["date0"] = 'DD/MM/YYYY'
      
      render :layout => "turk_hit"
      return
    end
    
    # do some validation on the form post
    @errors = []
    @invalid_bands = []
    show_count = 0
    parser = ShowParser.new(nil)
    
    for i in (0...60)
      date = params["date_#{i}"]
      bands = params["bands_#{i}"]
      
      if (date.blank? && bands.blank?)
        last_index = i
        break
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
    elsif (@invalid_bands.size / show_count.to_f) < 0.4
      # We can tolerate some errors
      @invalid_bands = []
    end
    
    if @errors.size > 0 || @invalid_bands.size > 0
      logger.info("Errors submitting form")
    else
      @success = true
    end
    
    render :layout => "turk_hit"
  end
  
end