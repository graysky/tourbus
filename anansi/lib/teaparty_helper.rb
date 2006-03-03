# Class to help with parsing Teaparty show listings
class TeapartyHelper


  # The table cols for the teaparty show listings
  def self.table_columns
    { 0 => [:date, :time], 1 => :bands}
  end
  
  # Preprocess the bands text and return the modified
  # result
  def self.preprocess_bands_text(text)
    # Change "Endgame with Crisis Bureau" to "Endgame, Crisis Bureau"
    # to make it standard
    text.sub!(/with/, ',')
    # And sometimes bands are special guests
    text.sub!(/special guests/, '')
    text
  end
  
  # Divides band names
  def self.band_separator
    ','
  end
  
  # Marker to find the table of shows
  def self.marker_text
    ["Event Title"]
  end

end