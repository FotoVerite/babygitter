module Babygitter
  
  class NoMasterBranchError < StandardError
  end
    
  class Repo
  
    attr_accessor :total_commits, :master_branch, :branches, :branch_names, :authors_names, :began, :lastest_commit, :remote_url,
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
      set_master_branch(master_branch_name)
      bisect_branches
    end
  
    def get_all_commits_in_repo
      @branches.collect(&:commits).flatten.sort_by { |k| k.authored_date }.reverse
    end
  
    def get_total_uniq_commits_in_repo
      get_all_commits_in_repo.collect(&:id).uniq.size
    end
  
    def last_commited_commit
      get_all_commits_in_repo.first
    end
  
    def first_committed_commit
      get_all_commits_in_repo.last
    end
  
    def get_branch_names(repo)
      repo.heads.collect(&:name)
    end
  
    def create_branches(repo)
      @branch_names.collect {|branch_name| 
      Branch.new(branch_name ,Grit::Commit.find_all(repo, branch_name).sort_by { |k| k.authored_date}.reverse)}
    end
  
    def get_authors
      @branches.collect(&:author_names).flatten.uniq.sort_by { |k| k.downcase }
    end
  
    def get_remote_url
      unless @bare
        remote_url = @config.fetch('remote.origin.url').clone
        if remote_url =~ /^git:\/\/github.com/
          remote_url.gsub!(/^git/, "http")
          remote_url.gsub!(/.git$/, "")
        elsif remote_url =~ /^git@github.com/
          remote_url.gsub!(/^git@github.com:/, "http://github.com/")
          remote_url.gsub!(/.git$/, "")
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
      unless @bare
        project_name = @config.fetch("remote.origin.url").clone
        project_name.gsub!(/.*?\/|.*?:|.git/, "")
      else
        Babygitter.repo_path.gsub(/.*\/(?!\s)|\.git$|\/$/, "") 
      end
    end
    
    def submodule_codes
      `cd #{@path.gsub(/\/.git$/, "")}; git submodule` unless @bare
    end
  
    def set_master_branch(master_branch_name)
      master_branch_name = get_master_branch if master_branch_name == nil
      @branches.map {|branch| branch.is_master_branch, @master_branch = true, branch if branch.name == master_branch_name}
    end
  
    def bisect_branches
      other_branches = @branches - [@master_branch] 
      for branch in other_branches
        comparative_array = @branches - [branch]
        uniq_commits = branch.commits.map {|commits| commits.id}
        comparative_array.map {|b| uniq_commits -= b.commits.map {|commits| commits.id}}
        unless uniq_commits.size == 0
          index = branch.commits.map(&:id).index(uniq_commits.last)
          return branch.unique_commits =  branch.commits[0..index]
        end 
      end
    end
  
    def branches_that_contain_commit(commit)
      `git --git-dir=#{@path} branch --contains #{commit}`.gsub!(/\* /, "").split("\n")
    end
    
  
    def inspect
      %Q{#<Babygitter::Repo #{@project_name}>}
    end
  
  end
end