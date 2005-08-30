require 'digest/sha1'

class Hash
  # Return the first 40 characters of the hashed string
  def self.hashed(str)
    Digest::SHA1.hexdigest("tourbus--#{str}--")[0..39]
  end
end