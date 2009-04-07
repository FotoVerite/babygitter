module Babygitter
  class RepoAnalyzer
    # A Branch contains the basic informtion of what makes up the git branch
    class Branch
      include DateTimeArrays
      include FolderAnalysisMethods
      
       attr_accessor :is_master_branch, :unique_commits, :branched_at  
       attr_reader :name, :author_names, :authors, :commits, :total_commits, :began, :latest_commit
     
        def initialize(name, commits)
          @name = name
          @commits = commits
          @total_commits = commits.size
          @author_names = get_author_names
          @authors = create_authors
          @began = commits.last 
          @branched_at = commits.last 
          @latest_commit = commits.first
          @is_master_branch = false
          @unique_commits = nil
          @mapped_diffs = map_commits_to_diff_state_by_week
          @folder_array = get_array_of_mapped_folder_names
        end
      
        # Gets a list authors who have committed to this branch
        # * sort by authors name
        # * remove the duplicates wih uniq
        def get_author_names
          @commits.sort_by {|k| k.author.name.downcase}.collect {|commit| commit.author.name}.uniq
        end
      
        # Conver to diff state through gruff and map those by week
        # * call sorted_commits_by_week to sort commits by week into arrays
        # * map those arrays of commits and convert them to diff states
        # * flatten array of diff states so they are contained by week and not by commit. 
        # TODO this method is incredibly slow due to going through the command line. Improve!
        def map_commits_to_diff_state_by_week
          sorted_commits_by_week.map {|array_of_commits| array_of_commits.map(&:stats).map(&:to_diffstat).flatten }
        end
      
        # Create the authors objects for the branch
        # * creates an grouped_commits_array  of arrays the size of the author_names array
        # * sorts the commits by date and reveres this so the dates go from newest to olders
        # * goes through the sorted commits and finds the index of that commit's author in author_names array
        # * adds that commit to the group_commits_array
        # * takes each array in grouped_commits_array and creates an author object
        def create_authors
          grouped_commits_array = Array.new(@author_names.size).map {|a| a = []}
          sorted_commits = @commits.sort_by {|k| k.date}.reverse
          sorted_commits.map {|commit|
            index = @author_names.index(commit.author.name)
            grouped_commits_array[index] << commit }
          grouped_commits_array.map {|grouped_commits| Author.new(grouped_commits)}
        end
      
        # Sorts the commits by week into an array of arrays to plot out with gruff      
        def sorted_commits_by_week
          sort_array = create_active_date_array(@began.date, @latest_commit.date)
          mapped_commits_array = Array.new(sort_array.size).map {|a| a = []}
          for commit in @commits.reverse
            index = sort_array.index(commit.date.strftime("%U %Y"))
            mapped_commits_array[index] << commit
          end
          mapped_commits_array
        end
      
        # Gets the total line added by week to the git repository
        # TODO use this in an actual graph
        def get_total_lines_added_by_week
          @mapped_diffs.map {|week| week.map {|c| c.additions - c.deletions}}.map {|a| a.inject(0) {|result, number| result += number}}
        end
      
        def inspect
          %Q{#<Babygitter::Branch #{@total_commits} #{@name}>}
        end
        
      end
     
  end
end