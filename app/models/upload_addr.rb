# Unique email address for bands/fans to use to send comments/photos
class UploadAddr < ActiveRecord::Base

  # Random words that will be combined to form a unique email address
  RANDOM_WORDS = [ 'tour', 'bus','snow','ice','up','down','tree','king','live','song','buzz',
'band','rock','ace','next','easy','go','cat','dog','salt','hot','cold','net','car','bike','drum',
'kick','bass','amp','club','dark','punk','star','can','pick','head','lock','key','end','game',
'ruby','java','code','free','fire','cash','iron','blue','eyes','rip','cell','kit']

  # The email domain, for now. 
  # TODO Change when we have our real domain
  EMAIL_DOMAIN = "figureten.com"

  # Make sure that this address is unique
  validates_uniqueness_of :address
  
  # Who the address is attached to
  belongs_to :band
  belongs_to :fan
  
  # The email domain we're using
  def self.Domain
    return EMAIL_DOMAIN
  end 
  
  # Quick check to see if a given email prefix (everything up to the @mytourb.us)
  # is of the pattern we use. This is to prevent extra hits to the db when there
  # is a lot of spam to filter out.
  def self.valid_address?(prefix)
  
  end
  
  # Generate a new attempt at a unique address pre-fix like "down42tree".
  # Caller should use check the validity of it
  # Caller will have to tack on "@foo.com"
  def self.generate_address
    
    # Need 3 random numbers to index into the words and a number <100.
    idx1 = rand(RANDOM_WORDS.length)
    idx2 = rand(RANDOM_WORDS.length)
    rand_num = rand(100)
    
    # Put the address together
    addr = ""
    
    addr << "#{RANDOM_WORDS[idx1]}"
    addr << "#{rand_num}"
    addr << "#{RANDOM_WORDS[idx2]}"
    
    #puts "Random address: #{addr}"
    
    return addr
  end
end
