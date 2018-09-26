%COMPUTEEXACTMARGINALSBP Runs exact inference and returns the marginals
%over all the variables (if isMax == 0) or the max-marginals (if isMax == 1). 
%
%   M = COMPUTEEXACTMARGINALSBP(F, E, isMax) takes a list of factors F,
%   evidence E, and a flag isMax, runs exact inference and returns the
%   final marginals for the variables in the network. If isMax is 1, then
%   it runs exact MAP inference, otherwise exact inference (sum-prod).
%   It returns an array of size equal to the number of variables in the 
%   network where M(i) represents the ith variable and M(i).val represents 
%   the marginals of the ith variable. 
%
% Copyright (C) Daphne Koller, Stanford University, 2012


function M = ComputeExactMarginalsBP(F, E, isMax)

% initialization
% you should set it to the correct value in your code

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% Implement Exact and MAP Inference.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P = CreateCliqueTree(F, E);
Pc = CliqueTreeCalibrate(P, isMax);

V = unique([F(:).var]);
templateFactor = struct();
templateFactor.var = [];
templateFactor.card = [];
templateFactor.val = [];
for i = 1:length(V)
    M(i) = templateFactor;
end

neighbors = sum(Pc.edges,1);
[srt_neighbors,ind] = sort(neighbors);

for i = 1:length(ind)
    node = ind(i);
    scope = Pc.cliqueList(node).var;
    for j = 1:length(scope)
        if isempty(M(scope(j)).var)
            varsToSumOut = setdiff(scope,scope(j));
            M(scope(j)) = FactorMarginalization(Pc.cliqueList(node),varsToSumOut);
            M(scope(j)).val = M(scope(j)).val/sum(M(scope(j)).val);
        end
    end
end
