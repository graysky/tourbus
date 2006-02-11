module FanPublicHelper
  def fan_bio_for_editing
    if @fan.bio != ""
      "<div id='fan_bio'>#{@fan.bio}</div>"
    else
      "<div id='fan_bio'></div>"
    end
  end
end
