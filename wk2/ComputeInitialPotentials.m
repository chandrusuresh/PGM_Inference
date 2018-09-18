%COMPUTEINITIALPOTENTIALS Sets up the cliques in the clique tree that is
%passed in as a parameter.
%
%   P = COMPUTEINITIALPOTENTIALS(C) Takes the clique tree skeleton C which is a
%   struct with three fields:
%   - nodes: cell array representing the cliques in the tree.
%   - edges: represents the adjacency matrix of the tree.
%   - factorList: represents the list of factors that were used to build
%   the tree. 
%   
%   It returns the standard form of a clique tree P that we will use through 
%   the rest of the assigment. P is struct with two fields:
%   - cliqueList: represents an array of cliques with appropriate factors 
%   from factorList assigned to each clique. Where the .val of each clique
%   is initialized to the initial potential of that clique.
%   - edges: represents the adjacency matrix of the tree. 
%
% Copyright (C) Daphne Koller, Stanford University, 2012


function P = ComputeInitialPotentials(C)

% number of cliques
N = length(C.nodes);

% initialize cluster potentials 
P.cliqueList = repmat(struct('var', [], 'card', [], 'val', []), N, 1);
P.edges = zeros(N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% First, compute an assignment of factors from factorList to cliques. 
% Then use that assignment to initialize the cliques in cliqueList to 
% their initial potentials. 

% C.nodes is a list of cliques.
% So in your code, you should start with: P.cliqueList(i).var = C.nodes{i};
% Print out C to get a better understanding of its structure.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P.edges = C.edges;
C.factorList = incSortFactor(C.factorList);

% % CliqueFactors = AssignFactors2Cliques(C.nodes,C.factorList);
% usedFactors = [];
% usedFactors1 = cell(1,N);
% assigned = [];
% for i = 1:N
%     for j = 1:length(C.factorList)
%         if length(intersect(C.nodes{i},C.factorList(j).var)) == length(C.factorList(j).var)
%             if ismember(j,usedFactors)
%                 continue;
%             end        
%             if isempty(P.cliqueList(i).val)
%                 P.cliqueList(i) = C.factorList(j);
%             else
%                 P.cliqueList(i) = FactorProduct(P.cliqueList(i),C.factorList(j));
%             end
%             usedFactors = [usedFactors,j];
%             usedFactors1{i} = [usedFactors1{i},j];
%         end
%     end
% end
factors = C.factorList;
nodes = C.nodes;
[nodeAdj,factorAdj] = varConnectivity(nodes,factors);
varCountInNode = sum(nodeAdj,2);
sortedSum = unique(sort(varCountInNode));
if sortedSum(1) == 0
    minVal = sortedSum(2);
else
    minVal = sortedSum(1);
end
ind = find(varCountInNode == minVal);
while max(sum(nodeAdj,2)) > 0
    varNum = ind(1);
    factorInd = find(factorAdj(varNum,:));
    nodeInd = find(nodeAdj(varNum,:));
    nodeNum = nodeInd(1);
    totalFactorVars = -1;
    maxFactorVarsInd = -1;
    for i = 1:length(factorInd)
        totalVars = intersect(factors(factorInd(i)).var,nodes{nodeNum});
        if length(totalVars) > totalFactorVars
            totalFactorVars = length(totalVars);
            maxFactorVarsInd = i;
        end
    end
    if maxFactorVarsInd > 0
        if isempty(P.cliqueList(nodeNum).val)
            P.cliqueList(nodeNum) = factors(factorInd(maxFactorVarsInd));
        else
            P.cliqueList(nodeNum) = FactorProduct(P.cliqueList(nodeNum),factors(factorInd(maxFactorVarsInd)));
        end
        nodeAdj(factors(factorInd(maxFactorVarsInd)).var,nodeNum) = 0;
        factorAdj(:,factorInd(maxFactorVarsInd)) = 0;
    else
        P.cliqueList(nodeNum).var = nodes{nodeNum}';
        for k1 = 1:length(nodes{nodeNum})
            P.cliqueList(nodeNum).card(k1) = C.card(nodes{nodeNum}(k1));
        end
        P.cliqueList(nodeNum).val = ones(1,prod(P.cliqueList(nodeNum).card));        
        nodeAdj(P.cliqueList(nodeNum).var,nodeNum) = 0;
    end
    varCountInNode = sum(nodeAdj,2);
    sortedSum = unique(sort(varCountInNode));
    if sortedSum(1) == 0 && length(sortedSum) > 1
        minVal = sortedSum(2);
    else
        minVal = sortedSum(1);
    end
    ind(1) = [];
    ind1 = find(varCountInNode == minVal);
    intInd = intersect(ind,ind1,'stable');
    diffInd = setdiff(ind1,ind);
    ind = [reshape(intInd,[1,length(intInd)]),reshape(diffInd,[1,length(diffInd)])];
end

% while varCount(end,2) > 0
%     minVar = varCount(1,1);
%     for i = 1:length(nodes)
%         if ismember(minVar, nodes{i})
%             
        
% factorList = cell(length(C.nodes),1);
% for i = 1:size(varCount,1)
%     for j = 1:length(C.nodes)
%         if ismember(varCount(i,1),C.nodes{j})
%             [factorList{j},factors] = AssignFactors2Cliques(C.nodes{j},factors);
%         end
%     end
% end
% keyboard