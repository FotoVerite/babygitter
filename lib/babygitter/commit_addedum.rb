module Grit
  
  class Commit
    
    def date_time_string
      date.strftime("%b %d %I:%M %p %Y")
    end
    
    def stats
      stats = @repo.commit_stats(self.sha, 1)[0][-1]
    end
      
  end
end