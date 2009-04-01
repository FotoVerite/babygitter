module Babygitter
  
  # A Branch contains the basic informtion of what makes up the git branch
  class Branch
      
     attr_accessor :is_master_branch, :unique_commits, :branched_at  
     attr_reader :name, :author_names, :authors, :commits, :total_commits, :began, :latest_commit
     
      def initialize(name, commits)
        @name = name
        @commits = commits
        @total_commits = commits.size
        @author_names = get_author_names
        @authors = create_authors
        @began = commits.last #TODO this is incorrect because all branches leads to the first commit.
        @branched_at = commits.last 
        @latest_commit = commits.first
        @is_master_branch = false
        @unique_commits = nil
        @mapped_diffs = sorted_commits_by_week.map {|array_of_commits| array_of_commits.map(&:stats).map(&:to_diffstat).flatten }
        @folder_array = get_array_of_mapped_folder_names
      end
      
      # Gets a list authors who have committed to this branch
      # * sort by authors name
      # * remove the duplicates wih uniq
      def get_author_names
        @commits.sort_by {|k| k.author.name.downcase}.collect {|commit| commit.author.name}.uniq
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
      
      # Creates an array of arrays that contain strings made up of the week of year number and year
      # this is used to map the commits by week. 
      def create_active_date_array
        active_date_array = []
        now = began.date
        i = 0
        weeks_repo_has_been_active = ((latest_commit.date - began.date ) / (60*60*24*1)).ceil
        while i <= weeks_repo_has_been_active
          active_date_array << now.strftime("%U %Y")
          now += (60*60*24*1)
          i += 1
        end
        active_date_array.uniq
      end
            
      def sorted_commits_by_week
        sort_array = create_active_date_array
        mapped_commits_array = Array.new(create_active_date_array.size).map {|a| a = []}
        for commit in @commits.reverse
          index = sort_array.index(commit.date.strftime("%U %Y"))
          mapped_commits_array[index] << commit
        end
        mapped_commits_array
      end
      
      def get_total_lines_added_by_week
        @mapped_diffs.map {|week| week.map {|c| c.additions - c.deletions}}.map {|a| a.inject(0) {|result, number| result += number}}
      end
      
      # Creates a hash from an array of folder names. 
      # Also deletes or adds the "" hash key for collecting files in the top level folder
      def create_hash_map(array)
        hash = {}
        array.map {|folder| hash[folder] = 0}
        if Babygitter.use_whitelist
          hash[""] = 0 unless Babygitter.marked_folders.find_all{ |item| item =~ /^program_folder$|^program folder/i }.empty?
        else
          hash[""] = 0 if Babygitter.marked_folders.find_all{ |item| item =~ /^program_folder$|^program folder/i }.empty?
        end
        hash
      end
      
      # Creates a hash from an array of folder names. 
      # Also deletes or adds the "" hash key for collecting files in the top level folder
      # Same principle as create_hash_map except the values are contained in arrays for data collection. 
      def create_hash_map_with_array(array)
        hash = {}
        array.map {|folder| hash[folder] = [0]}
        if Babygitter.use_whitelist
          hash[""] = [0] unless Babygitter.marked_folders.find_all{ |item| item =~ /^program_folder$|^program folder/i }.empty?
        else
          hash[""] = [0] if Babygitter.marked_folders.find_all{ |item| item =~ /^program_folder$|^program folder/i }.empty?
        end
        hash
      end
      
      # Recursively get the folder names inside a project
      # Goes as many levels deep as specifi 
      def get_array_of_mapped_folder_names
        array = []
        flattened_diffs = @mapped_diffs.flatten 
        i = 1 
        while i <= Babygitter.folder_levels.max
          folder_names = []
          for diff in flattened_diffs
           folder_names << diff.filename.scan(build_regexp(i)) 
          end
          #I hate this is there a better way. 
          i += 1
          array << folder_names.flatten.uniq          
        end
        array
      end
      
      # Creates the folder_array to turn into a hash of arrays for plotting the data
      # * Gets the arrays of folders by levels and selects the ones applicable to that level 
      # * Flattens the array of arrays and intersects it or removes folders in the Babygitter.marked_folders variable
      # * is then sent off to create_hash_map_with_array
      def folder_hash_with_arrays_for_level(folder_level)
        if Babygitter.use_whitelist 
          create_hash_map_with_array(@folder_array[0..(folder_level -1)].flatten & Babygitter.marked_folders)
        else
          create_hash_map_with_array(@folder_array[0..(folder_level -1)].flatten - Babygitter.marked_folders)
        end
      end
      
      # Creates the folder_array to turn into a hash for collection of data from diff stats
      # * Gets the arrays of folders by levels and selects the ones applicable to that level 
      # * Flattens the array of arrays and intersects it or removes folders in the Babygitter.marked_folders variable
      # * is then sent off to create_hash_map
      # TODO is there a clean way of combining this and folder_hash_with_arrays_for_level 
      def folder_hash_for_level(folder_level)
        if Babygitter.use_whitelist 
          create_hash_map(@folder_array[0..(folder_level -1)].flatten & Babygitter.marked_folders)
        else
          create_hash_map(@folder_array[0..(folder_level -1)].flatten - Babygitter.marked_folders)
        end
      end
      
      # Creates a hash to be used with gruff to plot out lines of codes commited to folder over weekly intervals
      def plot_folder_points(folder_level)
        stable_hash = folder_hash_with_arrays_for_level(folder_level)
        get_folder_commits_by_week_and_level(folder_level).each do |hash|
          hash.each_key do |key|
            stable_hash[key] << (stable_hash[key].last + hash[key])
          end
        end
        stable_hash
      end
      
      def get_folder_commits_by_week_and_level(folder_level)
        output = []
        diff_staff_by_week =  @mapped_diffs
          for array_of_diff_staff in diff_staff_by_week
            plot_hash =  folder_hash_for_level(folder_level).clone
            for diff in array_of_diff_staff
              key = find_key(folder_level, diff)
              plot_hash[key] = plot_hash[key] += (diff.additions - diff.deletions) unless plot_hash[key].nil?
            end
            output << plot_hash
          end
          output
      end
      
      # Finds the key of the hash that the diff should be put into 
      def find_key(folder_level, diff)
        i = folder_level
        key = nil
        while i > 0 && key == nil
          key = diff.filename.scan(build_regexp(i)).to_s if diff.filename.scan(build_regexp(i)).to_s != ""
          i -= 1
        end
        key = diff.filename.scan(/^.*?(?=\/)/).to_s unless key
        key
      end
      
      # Build a regexp to scane the diff states and their folder string
      # * build_regex(1) #=> /^.*?(?=\/)/
      # * build_regex(2) #=> /^.*?\/.*?(?=\/)/
      # * build_regex(3) #=> /^.*?\/.*?\/.*?(?=\/)/
      # TODO seperate this into it's own class
      def build_regexp(level)
        regexp_string = "^.*?"
        i = 1
        while i < level
          regexp_string += "\/.*?" 
          i +=1
        end
        regexp_string += "(?=\/)"
        Regexp.new(regexp_string)
      end
      
      def inspect
        %Q{#<Babygitter::Branch #{@total_commits} #{@name}>}
      end
     
  end
end