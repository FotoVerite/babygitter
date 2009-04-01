module Babygitter

  # A Branch contains the basic informtion for an author of a branch in a git repository
  class Author
    
     attr_accessor :name, :commits, :total_committed, :began, :latest_commit

      def initialize(commits)
        @name = commits.first.author.name
        @commits = commits
        @total_committed = commits.size
        @began = commits.last
        @latest_commit = commits.first
      end
      
      # Inserts the commits into the correct array for use in gruff graph
      # * creates the variable week_map through the method create_52_week_map 
      # * creates an array of 52 zeros
      # * using the index of where the commit can be found in week map it adds 1 to number found in at that index in plot_array
      # TODO put this in it's own class
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
      
      # Creates and array of arrays containing Week Number and Year starting from now and counting back 52 weeks.
      # TODO put this in it's own class 
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
      
      def inspect
          %Q{#<Babygitter::Author #{@total_committed} #{@name}>}
      end
      
  end
end