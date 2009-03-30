require File.dirname(__FILE__) + '/spec_helper'

  Babygitter.folder_levels = [2]
  GIT_REPO =Babygitter::Repo.new(File.join(File.dirname(__FILE__), "/dot_git"), :is_bare => true)
  MASTER_BRANCH = GIT_REPO.branches[2]
  BRANCH= GIT_REPO.branches[4]
  
describe Babygitter::Branch do
  
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
  
  it "should create a data_map_array" do
    BRANCH.create_active_date_array.should == ["40 2007", "41 2007", "42 2007", "43 2007", "44 2007", "45 2007", 
      "46 2007", "47 2007", "48 2007", "49 2007", "50 2007", "51 2007", "52 2007", "00 2008", "01 2008", "02 2008", 
      "03 2008", "04 2008", "05 2008", "06 2008", "07 2008", "08 2008", "09 2008", "10 2008", "11 2008", "12 2008", 
      "13 2008", "14 2008", "15 2008"]
  end
  
  it "should map the commits to an array by week" do 
    BRANCH.sorted_commits_by_week.first.first.should == BRANCH.began
    BRANCH.sorted_commits_by_week.first.size.should == 22
    BRANCH.sorted_commits_by_week.flatten.size.should == BRANCH.total_commits
  end
  
  it "should map total lines commited per week" do
    BRANCH.get_total_lines_added_by_week.should == [998, 324, 287, 716, 0, 0, 0, 0, 0, 0, 0, 68, 0, 0, 82, 291, 12, 18, 
     702, 358, 1293, 9, 111, 38, 0, 8, 92, 5, 0]
  end
  
  it "should create an array map for plotting lines commit by folder" do
    BRANCH.create_hash_map(["bin", "lib", "test"]).should == {""=> 0, "lib"=> 0, "bin"=> 0, "test"=> 0}
  end
  
  it "should fully map out the folders by depth" do 
    BRANCH.get_array_of_mapped_folder_names.should == [["bin", "lib", "test"], ["lib/grit", "test/fixtures"]]
  end
  
  it "should find the right key for the hash" do
    BRANCH.find_key(3, BRANCH.commits.first.stats.to_diffstat.flatten.first).should == "lib/grit"
    BRANCH.find_key(2, BRANCH.commits.first.stats.to_diffstat.flatten.first).should == "lib/grit"
    BRANCH.find_key(1, BRANCH.commits.first.stats.to_diffstat.flatten.first).should == "lib"
  end
  
  it 'should map out the diffs by folder, level and date' do
    BRANCH.get_folder_commits_by_week_and_level(2)[0..2].should == [{"test/fixtures"=>42, ""=>79, 
    "lib/grit"=>564, "lib"=>19, "bin"=>0, "test"=>294}, {"test/fixtures"=>131, ""=>6, "lib/grit"=>121, "lib"=>6, 
    "bin"=>0, "test"=>60}, {"test/fixtures"=>0, ""=>181, "lib/grit"=>53, "lib"=>1, "bin"=>0, "test"=>52}]
    BRANCH.get_folder_commits_by_week_and_level(1)[0..2].should == [{""=>79, "lib"=>583, "bin"=>0, "test"=>336}, 
    {""=>6, "lib"=>127, "bin"=>0, "test"=>191}, {""=>181, "lib"=>54, "bin"=>0, "test"=>52}]
  end
  
  it 'should map out the diffs by folder, level, date and take off blacklisted folders' do
    Babygitter.marked_folders = ['lib', 'bin', 'Program Folder']
    BRANCH.get_folder_commits_by_week_and_level(1)[0..2].should == [{"test"=>336}, {"test"=>191}, {"test"=>52}]
  end
  
  it 'should map out the diffs by folder, level  date and for whitelist folder if option is on' do
    Babygitter.use_whitelist = true
    Babygitter.marked_folders = ['test']
    BRANCH.get_folder_commits_by_week_and_level(1)[0..2].should == [{"test"=>336}, {"test"=>191}, {"test"=>52}]
  end
  
  
  it "should plot the points out correctly by level of depth" do
    BRANCH.plot_folder_points(1).should ==   {""=>[0, 79, 85, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266,
    274, 284, 284, 284, 284, 284, 284, 284, 285, 285, 285, 286, 286, 286, 286], "lib"=>[0, 583, 710, 764, 790, 790, 790, 
    790, 790, 790, 790, 790, 836, 836, 836, 874, 908, 920, 921, 942, 1074, 1117, 1123, 1169, 1188, 1188, 1190, 1251, 1256, 1256], 
    "test"=>[0, 336, 527, 579, 1269, 1269, 1269, 1269, 1269, 1269, 1269, 1269, 1291, 1291, 1291, 1327, 1574, 1574, 1591, 2272, 2498,
    3748, 3751, 3815, 3834, 3834, 3839, 3870, 3870, 3870], "bin"=>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0]}
    BRANCH.plot_folder_points(2).should == {""=>[0, 79, 85, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 266, 274,
    284, 284, 284, 284, 284, 284, 284, 285, 285, 285, 286, 286, 286, 286], "test/fixtures"=>[0, 42, 173, 173, 783, 783, 783, 783,
    783, 783, 783, 783, 784, 784, 784, 784, 985, 985, 985, 1646, 1748, 2903, 2905, 2910, 2910, 2910, 2910, 2910, 2910, 2910],
    "lib/grit"=>[0, 564, 685, 738, 763, 763, 763, 763, 763, 763, 763, 763, 809, 809, 809, 843, 876, 888, 889, 910, 1041, 1084, 
    1090, 1135, 1154, 1154, 1155, 1214, 1219, 1219], "lib"=>[0, 19, 25, 26, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 31, 32, 32, 
    32, 32, 33, 33, 33, 34, 34, 34, 35, 37, 37, 37], "test"=>[0, 294, 354, 406, 486, 486, 486, 486, 486, 486, 486, 486, 507, 507, 
    507, 543, 589, 589, 606, 626, 750, 845, 846, 905, 924, 924, 929, 960, 960, 960], "bin"=>[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]}
  end
  
  it "should declare itself the master branch correctly" do
    BRANCH.is_master_branch.should == false
    MASTER_BRANCH.is_master_branch.should == true
  end
  
  it "should inspect correctly" do
    BRANCH.inspect.should == "#<Babygitter::Branch 105 >"
  end
      
end