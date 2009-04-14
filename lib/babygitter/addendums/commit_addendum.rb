module Grit
  
  class Commit
    
    # Convience method for accessing a commits date in printable fashion
    def date_time_string
      date.strftime("%b %d %I:%M %p %Y")
    end
    
  end
end