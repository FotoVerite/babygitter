module Babygitter
  module FolderAnalysisMethods
    
     # Creates a hash from an array of folder names. 
      # Also deletes or adds the "" hash key for collecting files in the top level folder
      def create_hash_map(array)
        hash = {}
        array.map {|folder| hash[folder] = 0}
        if Babygitter.use_whitelist
          hash[""] = 0 if Babygitter.marked_folders.find { |item| item =~ /^program_folder$|^program folder/i }
        else
          hash[""] = 0 unless Babygitter.marked_folders.find{ |item| item =~ /^program_folder$|^program folder/i }
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
          i += 1
          array << folder_names.flatten.uniq          
        end
        array
      end
    
      # Creates the folder_array to turn into a hash for collection of data from diff stats
      # * Gets the arrays of folders by levels and selects the ones applicable to that level 
      # * Flattens the array of arrays and intersects it or removes folders in the Babygitter.marked_folders variable
      # * is then sent off to create_hash_map
      def folder_hash_for_level(folder_level)
        if Babygitter.use_whitelist 
          create_hash_map(@folder_array[0..(folder_level -1)].flatten & Babygitter.marked_folders)
        else
          create_hash_map(@folder_array[0..(folder_level -1)].flatten - Babygitter.marked_folders)
        end
      end
    
      # Creates a hash to be used with gruff to plot out lines of codes commited to folder over weekly intervals
      def plot_folder_points(folder_level)
        folder_commits = get_folder_commits_by_week_and_level(folder_level)
        stable_hash = create_stable_hash(folder_commits)
        folder_commits.each do |hash|
          hash.each_key do |key|
            stable_hash[key] << (stable_hash[key].last + hash[key])
          end
        end
        return stable_hash
      end
    
      def create_stable_hash(folder_commits)
        stable_hash = {}
        folder_commits.first.each_key {|key| stable_hash[key] = [0] }
        return stable_hash
      end
    
      # Collects the diff states by folder
      # Folders the diffs are mapped to depends on inputed folder_level
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
    
  end
end