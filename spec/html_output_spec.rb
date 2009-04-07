require File.dirname(__FILE__) + '/spec_helper'
include Babygitter::HtmlOutput

describe Babygitter::HtmlOutput do

  it "should list the authors of the repo in a readible manner" do 
   authors_list(GIT_REPO.authors_names).should == "Chris Wanstrath, Cristi Balan, Dustin Sallings, " + 
  "Kamal Fariz Mahyuddin, rick, Scott Chacon, Tim Carey-Smith, tom, Tom Preston-Werner and Wayne Larsen have"
  end

  it "should list the authors commits of the repo in a readible manner" do 
    committer_detail(GIT_REPO.branches.first.authors.first.commits[0..3], "").should == 
    "<li>timeout code and tests <cite>Chris Wanstrath Mar 30 11:50 PM 2008</cite> <tt>30e367c</tt></li>" +
   "\n<li>add timeout protection to grit <cite>Chris Wanstrath Mar 30 07:31 PM 2008</cite> <tt>5a09431</tt></li>" +
    "\n<li>support for heads with slashes in them <cite>Chris Wanstrath Mar 29 11:31 PM 2008</cite> <tt>e1193f8</tt></li>" +
    "\n<li>Touch up Commit#to_hash\n\n* Use string instead of symbol keys\n* Return parents as 'id' =&gt; ID rather than array " +
    "of id strings <cite>Chris Wanstrath Mar 10 09:10 PM 2008</cite> <tt>ad44b88</tt></li>"
  end

  it "should display links to each author for branch" do
    author_links(GIT_REPO.branches.first).should == ""
  end

  it "should display links to  author correctly if there is only one for branch" do
    GIT_REPO.branches.first.stub!(:author_names).and_return(['Matthew Bergman'])
    author_links(GIT_REPO.branches.first).gsub(/\s+/, ' ').should == " <ul class=\"page_control\">" +
  " <li> Only <a id=\"#nonpack_Matthew_Bergman\">Matthew Bergman</a> has committed to nonpack </li> </ul> " 
  end

  it "should list the branch names in a readible manner" do
    branch_names_list(GIT_REPO.branch_names).strip.should == "<ul class=\"page_control\">\n  <li>\n    "+
    "<a href=\"#nonpack\">nonpack</a>\n  </li>\n  <li>\n    <a href=\"#test/master\">test/master</a>\n  </li>\n  <li>\n    "+
    "<a href=\"#master\">master</a>\n  </li>\n  <li>\n    <a href=\"#test/chacon\">test/chacon</a>\n  </li>\n</ul>\n"
  end

  it "should output the branch synopsis in useable html" do
   branch_synopsis(GIT_REPO.branches.first).gsub(/\s+/, ' ').should =="<p>Last commit was <tt><tt>ca8a30f</tt></tt> by Scott Chacon on Apr 18 07:27 PM 2008</p>
  <p>They have committed a total of 107 branches</p><p>nonpack is a stub with no unique commits </p>"
  end
  
end