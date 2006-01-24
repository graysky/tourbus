module BandPublicHelper
  def band_bio_for_editing
    if @band.bio != ""
      "<div id='band_bio'>#{@band.bio}</div>"
    else
      "<div id='band_bio'>No bio has been written for this band</div>"
    end
  end
end
