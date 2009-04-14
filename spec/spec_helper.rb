require 'spec'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'fotoverite_babygitter'
Babygitter.folder_levels = [2]

#GIT_REPO =Babygitter::RepoAnalyzer.new("spec/dot_git", :is_bare => true)
#MASTER_BRANCH = GIT_REPO.branches[2]
#BRANCH= GIT_REPO.branches[4]
#AUTHOR = BRANCH.authors.first

Spec::Runner.configure do |config|
  
end
