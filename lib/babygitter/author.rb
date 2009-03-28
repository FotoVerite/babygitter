module Babygitter
  
  class Author
    
     attr_accessor :name, :commits, :total_committed, :began, :latest_commit

      def initialize(commits)
        @name = commits.first.author.name
        @commits = commits
        @total_committed = commits.size
        @began = commits.last
        @latest_commit = commits.first
      end
      
      def create_52_week_map
        array = []
        now = Time.now
        i = 0
        while i < 52
          array << now.strftime("%U %Y")
          now -= (60*60*24*7)
          i += 1
        end
        array.reverse
      end
      
      def create_bar_data_points 
        week_map = create_52_week_map
        points_array = Array.new(52, 0)
        for commit in @commits
          unless week_map.index(commit.date.strftime("%U %Y")) == nil
            index = week_map.index(commit.date.strftime("%U %Y"))
            points_array[index] +=1
          end
        end
        points_array
      end
      
  end
end