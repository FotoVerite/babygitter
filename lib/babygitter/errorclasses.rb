module Babygitter
  module Errorclasses
    # Standard Error, happens when there is no branch called master and no master branch is given in the options  
     class NoMasterBranchError < StandardError
     end

     class NoBranchWithNameGivenError < StandardError
     end
   
  end
end