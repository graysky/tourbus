# Extra methods for arrays
class Array
  
  # Get num random elements from the array
  def random(num = self.size)
    rands = []
    while rands.size < num and rands.size < self.size
      n = rand(self.size)
      rands << n if !rands.include?(n)
    end
    
    rands.sort { rand }.map {|r| self.at(r) }
  end
   
end