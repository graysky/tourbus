# Class to help with parsing Teaparty show listings
class TeapartyHelper


  # The table cols for the teaparty show listings
  def self.table_columns
    { 0 => [:date, :time], 1 => :bands}
  end
  
  def self.band_separator
    ','
  end
  
  def self.marker_text
    ["Event Title"]
  end

end