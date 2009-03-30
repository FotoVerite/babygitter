require File.dirname(__FILE__) + '/spec_helper'

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
  
  it "should display links to each author for branch" do
    GIT_REPO.author_links(GIT_REPO.branches.first).should == "<ul class='page_control'><li><a href=#nonpack_ChrisWanstrath>" +
    "Chris Wanstrath</a>,</li>\n<li><a href=#nonpack_CristiBalan>Cristi Balan</a>,</li>\n" +
    "<li><a href=#nonpack_DustinSallings>Dustin Sallings</a>,</li>\n"+
    "<li><a href=#nonpack_KamalFarizMahyuddin>Kamal Fariz Mahyuddin</a>,</li>\n"+
    "<li><a href=#nonpack_rick>rick</a>,</li>\n<li><a href=#nonpack_ScottChacon>Scott Chacon</a>,</li>\n"+
    "<li><a href=#nonpack_TimCarey-Smith>Tim Carey-Smith</a>,</li>\n<li><a href=#nonpack_tom>tom</a>,</li>\n" + 
    "<li><a href=#nonpack_TomPreston-Werner>Tom Preston-Werner</a>,</li>\n" +
    "<li><a href=#nonpack_WayneLarsen>Wayne Larsen</a> have committed to nonpack</li>\n</ul>"
  end
  
  it "should display links to  author correctly if there is only one for branch" do
    GIT_REPO.branches.first.stub!(:author_names).and_return(['Matthew Bergman'])
    GIT_REPO.author_links(GIT_REPO.branches.first).should == "<ul class='page_control'>\n"+
    "<li>Only <a href=#nonpack_MatthewBergman>Matthew Bergman</a> has committed to nonpack</li>\n</ul>"
  end
  
  it "should list the branch names in a readible manner" do
    GIT_REPO.branch_names_list(GIT_REPO.branches).should == "<ul class='page_control'><li><a href=#nonpack>nonpack</a></li>
<li><a href=#test/master>test/master</a></li>\n<li><a href=#master>master</a></li>
<li><a href=#test/chacon>test/chacon</a></li>\n<li>and <a href=#testing>testing</a></li>
</ul>"
  end
  
  it "should output the branch synopsis in useable html" do
    GIT_REPO.branch_synopsis(GIT_REPO.branches.first).should =="<p>Last commit was <tt><tt>ca8a30f</tt></tt> by Scott Chacon on Apr 18 07:27 PM 2008</p>
<p>They have committed a total of 107 branches</p><p>nonpack is a stub with no unique commits </p>"
  end
  
  it "should output the number of unique commits" do
    GIT_REPO.branches.first.stub!(:unique_commits).and_return([1,2,3])
    GIT_REPO.branched_when(GIT_REPO.branches.first).should == "<p>There are 3 unique commits for this branch</p>"
  end
  
  it "should display if there are no unique commits" do
    GIT_REPO.branches.first.stub!(:unique_commits).and_return(nil)
    GIT_REPO.branched_when(GIT_REPO.branches.first).should == "<p>nonpack is a stub with no unique commits </p>"
  end
  
  
end

