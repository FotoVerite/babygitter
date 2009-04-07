module Babygitter
 
  class RepoAnalyzer
    include Errorclasses
  
    attr_reader :total_commits, :master_branch, :branches, :branch_names, :authors_names, :began, :lastest_commit, :remote_url,
    :submodule_list, :project_name
  
    def initialize(path, options = {}, master_branch_name=nil)
      Babygitter.repo_path = path
      repo = Grit::Repo.new(path, options)
      @path = repo.path
      @bare = options[:is_bare]
      @config = (Grit::Config.new(repo))
      @remote_url = get_remote_url
      @master_branch = nil
      @branch_names = get_branch_names(repo)
      @branches = create_branches(repo)
      @authors_names = get_authors
      @began = first_committed_commit
      @lastest_commit = last_commited_commit
      @total_commits = get_total_uniq_commits_in_repo
      @submodule_list = submodule_codes
      @project_name = get_project_name.capitalize
      @branched_commit_found_for_branches = []
      set_master_branch(master_branch_name)
      find_unique_commits_per_branch
      analyze_branches
      @branched_commit_found_for_branches = nil
    end
  
    # Gets all the commits in the repo from all branches and sorts them from newest to oldest
    # TODO should this be a private method. 
    def get_all_commits_in_repo
      @branches.collect(&:commits).flatten.sort_by { |k| k.authored_date }.reverse
    end
  
    # Gets the amount of uniq commits in the repo
    # * Calls get_all_commits_in_repo
    # * collects the commits' commit ids. We do this because each Grit::Commit is unique
    # * flatten the collected array and call size on it. 
    def get_total_uniq_commits_in_repo
      get_all_commits_in_repo.collect(&:id).uniq.size
    end
  
    # Gets the last commited commit
    # * Calls get_all_commits_in_repo
    # * Gets the first commit in the array
    def last_commited_commit
      get_all_commits_in_repo.first
    end
    
    # Gets the last commited commit
    # * Calls get_all_commits_in_repo
    # * Gets the last commit in the array
    def first_committed_commit
      get_all_commits_in_repo.last
    end
    
    # Gets the names of the branches in the repo.
    # Uses Grit:Repo.heads
    def get_branch_names(repo)
      repo.heads.collect(&:name)
    end
    
    # Creates the Branch objects for the Repo
    # * Calls collect on branch_names
    # * Calls Grit::Commit with the name of the branch to get the commits associated with it
    # * Sorts the commit by latest to earliest
    # * Creates a branch object for each name in branch with these commits
    def create_branches(repo)
      @branch_names.collect {|branch_name| 
      Branch.new(branch_name ,Grit::Commit.find_all(repo, branch_name).sort_by { |k| k.authored_date}.reverse)}
    end
  
    # Collects the names of the authors in each branch, calls unique on them and sorts them by alphabetically.
    def get_authors
      @branches.collect(&:author_names).flatten.uniq.sort_by { |k| k.downcase }
    end
  
    def get_remote_url
      unless @bare
        remote_url = @config.fetch('remote.origin.url').clone
        if remote_url =~ /^git:\/\/github.com/
          remote_url.gsub!(/^git/, "http").gsub!(/.git$/, "")
        elsif remote_url =~ /^git@github.com/
          remote_url.gsub!(/^git@github.com:/, "http://github.com/").gsub!(/.git$/, "")
        else
          ""
        end
      else
        ""
      end        
    end
  
    def get_master_branch
      error = NoMasterBranchError.new("No branch with name master, set variable master branch name")
      raise error unless @branch_names.index('master') != nil
      "master"
    end
  
    def get_project_name
        Babygitter.repo_path.gsub(/\/$/, "").gsub(/.*\/(?!\s)|\.git$|\/$/, "") 
    end
    
    def submodule_codes
      `cd #{@path.gsub(/\/.git$/, "")}; git submodule` unless @bare
    end
  
    def set_master_branch(master_branch_name)
      master_branch_name = get_master_branch if master_branch_name == nil
      error = NoBranchWithNameGivenError.new("No branch with name #{master_branch_name} is in the repository") 
      raise error unless  @branch_names.index(master_branch_name) != nil
      @branches.map {|branch| branch.is_master_branch, @master_branch = true, branch if branch.name == master_branch_name}
    end
    
    def find_unique_commits_per_branch
      for branch in @branches
        other_branches_commits = (@branches - [branch]).map(&:commits).flatten.map(&:id).uniq
        branch.commits.inject([]) do |result, commit|
          result << commit unless other_branches_commits.include?(commit.id)
          branch.unique_commits = result
        end
      end
    end
    
    
    def in_which_branches(commit_id)
      @branches.inject([]) do |result, branch| 
        result << branch.name if branch.commits.map(&:id).include?(commit_id)
        result
      end
    end
    
    def find_branch(name) 
      @branches.find {|branch| branch.name == name}
    end
    
    def analyze_branches
      go_down_branch_from_head(@master_branch)
    end

    def go_down_branch_from_head(branch)
      @branched_commit_found_for_branches << branch.name
      for commit in branch.commits
        branches_commit_is_in = in_which_branches(commit.id)
        if (branches_commit_is_in - @branched_commit_found_for_branches).size > 0
          branched_commits = (branches_commit_is_in - @branched_commit_found_for_branches)
          for name in branched_commits
            find_branch(name).branched_at = commit if commit.date > find_branch(name).branched_at.date
            go_down_branch_from_head(find_branch(name)) 
          end
        end
      end
    end
  
    def inspect
      %Q{#<Babygitter::Repo #{@project_name}>}
    end
  
  end
end