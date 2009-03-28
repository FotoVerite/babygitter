module Babygitter
  
  class Branch
      
     attr_accessor :is_master_branch, :unique_commits  
     attr_reader :name, :author_names, :authors, :commits, :total_commits, :began, :latest_commit
     
      def initialize(name, commits)
        @name = name
        @commits = commits
        @total_commits = commits.size
        @author_names = get_author_names
        @authors = create_authors
        @began = commits.last
        @latest_commit = commits.first
        @is_master_branch = false
        @unique_commits = nil
        @mapped_diffs = sorted_commits_by_week.map {|array_of_commits| array_of_commits.map(&:stats).map(&:to_diffstat).flatten }
        @folder_array = get_array_of_mapped_folder_names
      end
      
      def get_author_names
        @commits.sort_by {|k| k.author.name.downcase}.collect {|commit| commit.author.name}.uniq
      end
      
      def create_authors
        array = Array.new(@author_names.size).map {|a| a = []}
        sorted_commits = @commits.sort_by {|k| k.date}.reverse
        sorted_commits.map {|commit|
          index = author_names.index(commit.author.name)
          array[index] << commit }
        array.map {|grouped_commits| Author.new(grouped_commits)}
      end
      
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
      
      def create_hash_map(array)
        hash = {}
        array.map {|folder| hash[folder] = 0}
        hash[""] = 0
        hash
      end
      
      def create_hash_map_with_array(array)
        hash = {}
        array.map {|folder| hash[folder] = [0]}
        hash[""] = [0]
        hash
      end
      
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
      
      def plot_folder_points(levels)
        stable_hash = Babygitter.use_whitelist ? create_hash_map_with_array(Babygitter.marked_folders) :  create_hash_map_with_array(@folder_array[0..(levels -1)].flatten - Babygitter.marked_folders)
        get_folder_commits_by_week_and_level(levels).each do |hash|
          hash.each_key do |key|
            stable_hash[key] << (stable_hash[key].last + hash[key])
          end
        end
        stable_hash
      end
      
      def get_folder_commits_by_week_and_level(levels)
        output = []
        diff_staff_by_week =  @mapped_diffs
          for array_of_diff_staff in diff_staff_by_week
            plot_hash =  Babygitter.use_whitelist ? create_hash_map(Babygitter.marked_folders) :
            create_hash_map(@folder_array[0..(levels -1)].flatten - Babygitter.marked_folders).clone
            for diff in array_of_diff_staff
              key = find_key(levels, diff)
              plot_hash[key] = plot_hash[key] += (diff.additions - diff.deletions) unless plot_hash[key].nil?
            end
            output << plot_hash
          end
          output
      end
      
      def find_key(levels, diff)
        i = levels
        key = nil
        while i > 0 && key == nil
          key = diff.filename.scan(build_regexp(i)).to_s if diff.filename.scan(build_regexp(i)).to_s != ""
          i -= 1
        end
        key = diff.filename.scan(/^.*?(?=\/)/).to_s unless key
        key
      end
      
      def build_regexp(integer)
        regexp_string = "^.*?"
        i = 1
        while i < integer
          regexp_string += "\/.*?" 
          i +=1
        end
        regexp_string += "(?=\/)"
        Regexp.new(regexp_string)
      end
      
      def inspect
        %Q{#<Babygitter::Branch #{@total_commits} #{@id}>}
      end
     
  end
end