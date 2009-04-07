require File.dirname(__FILE__) + '/spec_helper'
include Babygitter::FolderAnalysisMethods

describe Babygitter::FolderAnalysisMethods do
  
  before(:each) do
    Babygitter.marked_folders = []
    Babygitter.use_whitelist = false
  end
  
  it "should create usuable regexs by level" do
    "folder_level_1/folder_level_2/file".scan(BRANCH.build_regexp(1)).to_s.should == "folder_level_1"
    "folder_level_1/folder_level_2/file".scan(BRANCH.build_regexp(2)).to_s.should == "folder_level_1/folder_level_2"
    "folder_level_1/folder_level_2/file".scan(BRANCH.build_regexp(3)).to_s.should == ""
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
  
end

