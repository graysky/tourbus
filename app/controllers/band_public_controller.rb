class BandPublicController < ApplicationController
  before_filter :find_band
  layout "public"
  upload_status_for :create_logo
  
  # The the band homepage
  def index
    p params
  end
  
  def change_logo
    puts "here I am!"
    @band.update_attributes(params[:band])
    @band.save
    
    path = @band.logo_options[:base_url] + "/logo/" + @band.logo_relative_path
    finish_upload_status "'#{path}'"
  end
  
  def set_bio
    @band.bio = params[:value]
    @band.save
    render :text => @band.bio
  end
  
  # Create a new tag of the specified type
  def create_tag
    # TODO Seems clumsy to have to make it "object", "method" in the params
    # array for the text_field_autocomplete. I don't see a "_tag" variant available.
    # Maybe I'm not understanding something here.
    tag_type = params[:type]
    tag_name = params[:tag][:name]
    
    # TODO Need to handle tag that already exists
    @band.add_tag(tag_type, tag_name)
    
    # Return the tag name 
    render :text => tag_name
  end
  
  # Called to auto-complete tag name
  def auto_complete_for_tag_name
    search = params[:tag][:name]
    puts "trying to auto complete tag for #{search}"
    
    tags = Tag.find(:all,
             :conditions => "name LIKE '#{search}%'",
             :limit => 10)

    for tag in tags
      puts "Hit: #{tag.name}"
    end
    
    render(
	:partial => "tag_hits", 
	:locals => 
		{
		:tags => tags, 
		}) 
    
  end
  
  private
  def find_band
    # temp: fix tihs
    @band = Band.find_by_band_id(params[:band_id])
    if @band.nil?
      @band = session[:band]
    end
    
  end
end
