require 'RMagick'
include Magick

# Helpers to auto-create image and html images of upcoming shows
# Assumes that it is called from an ActionController
module Badge
  
  def test_badge
    
  end
  
  protected
  
  # Get the HTML badge for the supplied object according
  # to the defined parameters.
  # obj => object that responds to :upcoming_shows
  # params => optional parameters to control display
  #   Params that can be understood:
  #   n => number of shows
  # 
  def get_html_badge(obj, params)
    
    num = params['n'] || 5 # Default to 5 shows
    
    # Get the shows to display
    shows = obj.upcoming_shows.first(num.to_i)
    
    # Render the template for the response
    html = render_to_string(:partial => "badge/html_badge", :layout => false,
            :locals => { :shows => shows, })
    
    # Remove new lines
    html.gsub!(/\n/, '')
    html.gsub!(/\r\n/, '')
    js = "document.write(\"#{html}\")"

    return js
  end
  
  # Get the image badge for the supplied author, either fan or band
  def get_image_badge(author)
    
    f = ImageList.new( get_badge_location(author) )
    return f
  end
  
  # Calculate the location of the badge for this author
  def get_badge_location(author)
    return nil if author.nil?
    
    location = "#{RAILS_ROOT}/tmp/cache/badges/"
    
    FileUtils.mkpath(location)    
    location << "badge_#{author.class.to_s.downcase}_#{author.id}.jpg"
    
    return location
  end
  
  # Send the image down the pipe
  def send_badge(img)
    blob = img.to_blob { self.format = 'JPG' }
  
    # Set the right content type
    @headers["Content-Type"] = "image/jpeg"
    
    # Look at gruff's base methods for this & other pieces of help
    send_data(blob, :filename => "badge.jpg", :type => 'image/jpeg')
  end
  
  # Create a new badge image and stream it back.
  # shows => the shows to put on the badge
  def create_image_badge(author, shows)
    # Generate the badge
    f = create_small_badge(shows)
    
    # Write out the new badge
    f.write( get_badge_location(author) )
  end
  
  private
  
  def create_small_badge(shows)
  
    # The small image is 170 (w) x 200 (h)
    background_image = RAILS_ROOT + "/graphics/badge_sm.jpg"
    
    height = 200
    width = 170
    
    canvas = Magick::ImageList.new(background_image)
    
    blackish = '#484A4C'
    darkblue = '#0F628B'

    # Create object to draw on top of background image. Writing text in RMagick
    # is called annotating, which is doc'd here:
    # http://www.simplesystems.org/RMagick/doc/draw.html#annotate
    text = Magick::Draw.new

    start_y = 40
    
    # How far to indent each section in x-coord
    show_x = 4
    band_x = 8
    venue_x = 8
    
    # How to push down y-coord between sections
    show_offset = 55
    band_offset = 14
    venue_offset = 14
    
    i = 0
    shows.each do |show|
      
      the_date = short_date(show.date)
      
      y_coord = start_y + i * show_offset

      draw = Magick::Draw.new

      # Draw the date heading
      # draw.annotate(img, width, height, x, y, text)
      draw.annotate(canvas, 0, 0, show_x, y_coord, the_date) do
        self.font = 'ArialB'
        #self.font_style = Magick::NormalStyle
        self.pointsize = 12
        self.gravity = Magick::NorthWestGravity
        self.font_weight = 700
        self.fill = blackish
      end
      
      # Get the band string, with hand-calculated max length
      band_names = band_string(show.bands, 27)

      y_coord = y_coord + band_offset
            
      # Draw the band names
      Magick::Draw.new.annotate(canvas, 0, 0, band_x, y_coord, band_names) do
        self.font = 'Arial'
        self.pointsize = 12
        self.gravity = Magick::NorthWestGravity
        self.font_weight = Magick::NormalWeight
        self.fill = darkblue
      end

      y_coord = y_coord + venue_offset
      venue_name = venue_string(show.venue, 27)
      
      # Draw the venue names
      Magick::Draw.new.annotate(canvas, 0, 0, venue_x, y_coord, venue_name) do
        self.font_family = 'courier'
        self.pointsize = 11
        self.gravity = Magick::NorthWestGravity
        self.font_weight = Magick::NormalWeight
        self.fill = blackish
      end
      
      i = i + 1
    end
    
    return canvas
  end
  
  def short_date(date)
    return "" if date.nil?
    date.strftime("%b %d")
  end
  
  # Format band names as best as possible within
  # the text limit
  def band_string(bands, text_limit)
    band_names = ""
    
    # TODO This needs real work to make it better
    # at fitting as much as it can
    
    first = true
    for band in bands
    
      escape_string(band.name)
      #puts "Examining: #{band.name} (#{band.name.length})"
      name = band.name[0...(text_limit - 1)]
      if band_names.length + name.length < text_limit
        
        band_names << " / " if !first # Add divider if needed
        
        band_names << name
        first = false
        #puts "It fits, now: #{band_names}"
      end
    end
  
    return band_names
  end
  
  def venue_string(venue, text_limit)
    venue_name = "@ "
    venue_name << escape_string(venue.name)
    return venue_name
  end
  
  # Escape strings
  def escape_string(s)
    s.gsub!('&#8217;','\'') # Single appos
    return s
  end
  
end