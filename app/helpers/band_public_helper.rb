module BandPublicHelper
  def band_bio_for_editing
    if @band.bio != ""
      "<div id='band_bio'>#{@band.bio}</div>"
    else
      "<div id='band_bio'></div>"
    end
  end
end
