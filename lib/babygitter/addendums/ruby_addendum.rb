class Symbol
  
  # Adding back in (&:attribute) method to map. 
  def to_proc
    lambda {|i| i.send(self)}
  end
  
end

class String   
  
  # Convience method for underscoring whitespace in a string
  def underscore
    gsub(/ /, "_")
  end

end