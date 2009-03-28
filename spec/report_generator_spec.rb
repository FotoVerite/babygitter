require File.dirname(__FILE__) + '/spec_helper'
require 'grit'

  GIT_REPO =Babygitter::ReportGenerator.new(File.join(File.dirname(__FILE__), "/dot_git"), :is_bare => true)

describe Babygitter::ReportGenerator do
  
  it "should list the authors of the repo in a readible manner" do 
    GIT_REPO.authors_list(GIT_REPO.authors_names).should == "Chris Wanstrath, Cristi Balan, Dustin Sallings, " + 
"Kamal Fariz Mahyuddin, rick, Scott Chacon, Tim Carey-Smith, tom, Tom Preston-Werner and Wayne Larsen have"
  end
  
  it "should list the authors commits of the repo in a readible manner" do 
    GIT_REPO.committer_detail(GIT_REPO.branches.first.authors.first.commits[0..3], "").should == 
    "<li>timeout code and tests <cite>Chris Wanstrath Mar 30 11:50 PM 2008</cite> <tt>30e367c</tt></li>" +
    "\n<li>add timeout protection to grit <cite>Chris Wanstrath Mar 30 07:31 PM 2008</cite> <tt>5a09431</tt></li>" +
    "\n<li>support for heads with slashes in them <cite>Chris Wanstrath Mar 29 11:31 PM 2008</cite> <tt>e1193f8</tt></li>" +
    "\n<li>Touch up Commit#to_hash\n\n* Use string instead of symbol keys\n* Return parents as 'id' =&gt; ID rather than array " +
    "of id strings <cite>Chris Wanstrath Mar 10 09:10 PM 2008</cite> <tt>ad44b88</tt></li>"
  end
end

