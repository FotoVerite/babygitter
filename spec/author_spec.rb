require File.dirname(__FILE__) + '/spec_helper'
  
describe Babygitter::RepoAnalyzer::Author do
  
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
  
  it "should create an array object that contains the data to plot the weekly commit graph" do
    Time.should_receive(:now).and_return(Time.utc(2008,"oct",1,20,15,1))
    AUTHOR.create_bar_data_points.should == [0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 2, 2, 0, 1, 0, 0, 2, 0, 0, 3, 0, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  end
  
  it "should inspect correctly" do
    AUTHOR.inspect.should == "#<Babygitter::Author Chris Wanstrath>"
  end
  
end