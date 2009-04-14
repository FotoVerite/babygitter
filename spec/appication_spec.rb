require File.dirname(__FILE__) + '/spec_helper'

describe Babygitter::ReportGenerator::Application do
  
  before(:each) do
    Babygitter.folder_levels = [1]
    Babygitter.marked_folders = []
    Babygitter.use_whitelist = false
  end
  
  it "should out the levels of folders being graphed being generated in an understandable manner" do
     Babygitter::ReportGenerator::Application.level_sentence.should == "level 1"
     Babygitter.folder_levels = [1,3]
     Babygitter::ReportGenerator::Application.level_sentence.should == "levels 1 and 3"
  end
  
  it "should prepare the file directories correctly" do
    Babygitter.repo_path = File.expand_path 'spec/dot_git'
    FileUtils.rm_r Babygitter.report_file_path if File.exists?(Babygitter.report_file_path)
    File.exists?(Babygitter.report_file_path).should == false
    Babygitter::ReportGenerator::Application.prepare_file_stucture
    File.exists?(Babygitter.report_file_path).should == true
    File.exists?(Babygitter.report_file_path + "/babygitter_images").should == true
    File.exists?(Babygitter.report_file_path + "/asset_images").should == true
  end
  
end

