require File.dirname(__FILE__) + '/spec_helper'

  GIT_REPO =Babygitter::Repo.new(File.join(File.dirname(__FILE__), "/dot_git"), :is_bare => true)
  BRANCH= GIT_REPO.branches[4]
  AUTHOR = BRANCH.authors.first
  
describe Babygitter::Author do
  
  it "should diplay the author's name" do
    AUTHOR.name.should == "Chris Wanstrath"
  end
  
  it "should display the amounts of commits by this author" do
    AUTHOR.total_committed.should == 17
  end
  
  it "should display the lastest commit by this author" do
    AUTHOR.latest_commit.id.should == "30e367cef2203eba2b341dc9050993b06fd1e108"
    AUTHOR.latest_commit.date.strftime("%b %d %I:%M %p %Y").should == "Mar 30 11:50 PM 2008"
    
  end
  
  it "should display the first commit by this author" do
    AUTHOR.began.id.should == "5f141d9c0181b8732c0ec2fab4967f0ffa24fa3f"
    AUTHOR.began.date.strftime("%b %d %I:%M %p %Y").should == "Oct 28 08:12 PM 2007"
    
  end
  
  it "should create an array of 52 datetimes leading back from now to be used in generating the graph" do
    Time.should_receive(:now).and_return(Time.utc(2008,"jan",1,20,15,1))
    AUTHOR.create_52_week_map.should == ["01 2007", "02 2007", "03 2007", "04 2007", "05 2007", "06 2007", 
      "07 2007", "08 2007", "09 2007", "10 2007", "11 2007", "12 2007", "13 2007", 
      "14 2007", "15 2007", "16 2007", "17 2007", "18 2007", "19 2007", "20 2007",
      "21 2007", "22 2007", "23 2007", "24 2007", "25 2007", "26 2007", "27 2007", 
      "28 2007", "29 2007", "30 2007", "31 2007", "32 2007", "33 2007", "34 2007", 
      "35 2007", "36 2007", "37 2007", "38 2007", "39 2007", "40 2007", "41 2007", 
      "42 2007", "43 2007", "44 2007", "45 2007", "46 2007", "47 2007", "48 2007",
      "49 2007", "50 2007", "51 2007", "00 2008"]
  end
  
  it "should create an array object that contains the data to plot the weekly commit graph" do
    Time.should_receive(:now).and_return(Time.utc(2008,"oct",1,20,15,1))
    AUTHOR.create_bar_data_points.should == [0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 2, 2, 0, 1, 0, 0, 2, 0, 0, 3, 0, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  end
  
  it "should inspect correctly" do
    AUTHOR.inspect.should == "#<Babygitter::Author Chris Wanstrath> >"
  end
  
end