class BandController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  def list
    @band_pages, @bands = paginate :band, :per_page => 10
  end

  def show
    @band = Band.find(params[:id])
  end

  def new
    @band = Band.new
  end

  def create
    @band = Band.new(params[:band])
    if @band.save
      flash[:notice] = 'Band was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @band = Band.find(params[:id])
  end

  def update
    @band = Band.find(params[:id])
    if @band.update_attributes(params[:band])
      flash[:notice] = 'Band was successfully updated.'
      redirect_to :action => 'show', :id => @band
    else
      render :action => 'edit'
    end
  end

  def destroy
    Band.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
