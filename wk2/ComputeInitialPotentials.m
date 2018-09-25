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

% % % CreateCliqueTree function in Submission script does not include the 
% % % field for cardinality. Include the following to fix the bug
if ~isfield(C,'card')
    V = unique([C.factorList(:).var]);
    % Setting up the cardinality for the variables since we only get a list 
    % of factors.
    C.card = zeros(1, length(V));
    for i = 1 : length(V),
         for j = 1 : length(C.factorList)
              if (~isempty(find(C.factorList(j).var == i)))
                    C.card(i) = C.factorList(j).card(find(C.factorList(j).var == i));
                    break;
              end
         end
    end
end

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

%% Assign factors to cliques starting from leaves (least connected) to root (most connected)
nodesConsidered = [];
factors2Nodes = cell(1,length(C.nodes));
edges = C.edges;
newF = C.factorList;
removedFactors = [];
nodesNotConsidered = C.nodes;
for k = 1:length(C.nodes)
	 bestNode = 0;
	 bestScore = inf;
	 for i=1:size(edges,1)
		  score = sum(edges(i,:));
		  if score > 0 && score < bestScore
				bestScore = score;
				bestNode = i;
		  end
     end
     if bestNode == 0
         bestNode = nodesNotConsidered(1);
     end
	 [factors2Nodes{k},removedFactors] = FindFactorsForCliques(C,edges,removedFactors,bestNode);
     edges(bestNode,:) = 0;
     edges(:,bestNode) = 0;
     nodesConsidered = [nodesConsidered,bestNode];
     nodesNotConsidered = 1:length(C.nodes);
     nodesNotConsidered(nodesConsidered) = [];
end

for i = 1:length(C.nodes)
    factorIdx = factors2Nodes{i};
    if ~isempty(factorIdx)
        P.cliqueList(i) = C.factorList(factorIdx(1));
    end
    for j = 2:length(factorIdx)
        P.cliqueList(i) = FactorProduct(P.cliqueList(i),C.factorList(factorIdx(j)));
    end
    miscScope = setdiff(C.nodes{i},P.cliqueList(i).var);
    if ~isempty(miscScope)
        unityFactor = struct();
        unityFactor.var = miscScope;
        unityFactor.card = C.card(miscScope);
        unityFactor.val = ones(1,prod(unityFactor.card));
        if ~isempty(factorIdx)
            P.cliqueList(i) = FactorProduct(P.cliqueList(i),unityFactor);
        else
            P.cliqueList(i) = unityFactor;
        end
    end
end