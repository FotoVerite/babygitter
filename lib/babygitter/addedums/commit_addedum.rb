module Grit
  
  class Commit
    
    def date_time_string
      date.strftime("%b %d %I:%M %p %Y")
    end
    
  end
end