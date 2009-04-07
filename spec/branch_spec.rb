require File.dirname(__FILE__) + '/spec_helper'
  
describe Babygitter::RepoAnalyzer::Branch do
  
  before(:each) do
    Babygitter.marked_folders = []
    Babygitter.use_whitelist = false
  end
  
  it "should diplay the author's name" do
    BRANCH.name.should == "testing"
  end
  
  it "should diplay the create author objects" do
    BRANCH.authors.size.should == 9
  end
  
  it "should diplay the total number of commits" do
     BRANCH.total_commits.should == 105
  end
   
  it "should find the lastest commit" do
    BRANCH.latest_commit.id.should == "2d3acf90f35989df8f262dc50beadc4ee3ae1560"
    BRANCH.latest_commit.date.strftime("%b %d %I:%M %p %Y").should == "Apr 12 10:39 PM 2008"
  end
  
  it "should find the when the branch began" do
    BRANCH.began.id.should == "634396b2f541a9f2d58b00be1a07f0c358b999b3"
    BRANCH.began.date.strftime("%b %d %I:%M %p %Y").should == "Oct 10 02:18 AM 2007"
  end
  
  it "should find the which commit the branch, branched from" do
    BRANCH.branched_at.id.should == "2d3acf90f35989df8f262dc50beadc4ee3ae1560"
    GIT_REPO.branches[2].branched_at.id.should == "634396b2f541a9f2d58b00be1a07f0c358b999b3"
  end
  
  it "should map the commits to an array by week" do 
    BRANCH.sorted_commits_by_week.first.first.should == BRANCH.began
    BRANCH.sorted_commits_by_week.first.size.should == 22
    BRANCH.sorted_commits_by_week.flatten.size.should == BRANCH.total_commits
  end
  
  it "should map total lines commited per week" do
    BRANCH.get_total_lines_added_by_week.should.equal? [998, 324, 287, 716, 0, 0, 0, 0, 0, 0, 0, 68, 0, 0, 82, 291, 12, 18, 
     702, 358, 1293, 9, 111, 38, 0, 8, 92, 5, 0]
  end
  
  it "should declare itself the master branch correctly" do
    BRANCH.is_master_branch.should == false
    MASTER_BRANCH.is_master_branch.should == true
  end
  
  it "should inspect correctly" do
    BRANCH.inspect.should == "#<Babygitter::Branch 105 testing>"
  end
      
end