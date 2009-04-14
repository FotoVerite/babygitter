module Babygitter
  
  module Errorclasses
    
    # Standard Error, happens when there is no branch called master and no master branch is given in the options  
     class NoMasterBranchError < StandardError
     end
     
     # Standard Error, happens when the master branch name given doesn't exist in the repo.   
     class NoBranchWithNameGivenError < StandardError
     end
   
  end
end