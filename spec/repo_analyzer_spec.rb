require File.dirname(__FILE__) + '/spec_helper'

describe Babygitter::RepoAnalyzer do
  
  it "should create a valid url if stored on github" do
    GIT_REPO.remote_url.should  == "http://github.com/schacon/grit"
  end
  
  it "should create a " do
    Grit::Config.should_receive(:fetch).and_return("http://somewhere")
    GIT_REPO.remote_url.should  == "http://github.com/schacon/grit"
  end
  
  it "should find the master branch name" do
    GIT_REPO.get_master_branch.should  == "master"
  end
  
  it "should get the git repository's project name" do
    GIT_REPO.project_name.should == "Dot_git"
  end
  
  it "should store all instances of the git branches" do
    GIT_REPO.branches.size.should == 5
  end
  
  it "should put all local branches" do
    GIT_REPO.branch_names.should == ["nonpack", "test/master", "master", "test/chacon", "testing"] 
  end
  
  it "should store the total number of commits" do
    GIT_REPO.total_commits.should == 107
  end
  
  it "should ascertain when the repo began" do
    GIT_REPO.began.id.should == "634396b2f541a9f2d58b00be1a07f0c358b999b3"
  end
  
  it "should get the submodule codes"
  
  it "should find the last committed commit" do
    GIT_REPO.lastest_commit.id.should == "ca8a30f5a7f0f163bbe3b6f0abf18a6c83b0687a"
  end
  
  it "should list all authors in an array" do
    GIT_REPO.authors_names.should == ["Chris Wanstrath", "Cristi Balan", "Dustin Sallings", "Kamal Fariz Mahyuddin", "rick", 
      "Scott Chacon", "Tim Carey-Smith", "tom", "Tom Preston-Werner", "Wayne Larsen"]
  end
  
  it "should find the designated branch" do
    GIT_REPO.find_branch("master").should == GIT_REPO.branches[2]
  end
  
  it "should find all the branches a commit is part of" do
     GIT_REPO.in_which_branches(GIT_REPO.branches.first.commits.first.id).should == ["nonpack", "master", "test/chacon"]
     GIT_REPO.in_which_branches(GIT_REPO.branches.first.commits[8].id).should == ["nonpack", "test/master", "master", "test/chacon", "testing"]
  end
   
  it "should inspect correctly" do
    GIT_REPO.inspect.should == "#<Babygitter::Repo Dot_git>"
  end
  
end

