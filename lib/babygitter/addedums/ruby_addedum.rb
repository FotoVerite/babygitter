class Symbol
  def to_proc
    lambda {|i| i.send(self)}
  end
end

class String   
   def underscore
     gsub(/ /, "_")
   end
end