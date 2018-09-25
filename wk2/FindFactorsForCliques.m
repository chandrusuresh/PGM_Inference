function [factors2Nodes,removedFactors] = FindFactorsForCliques(C,edges,removedFactors,bestNode)

scope = C.nodes{bestNode};

% % % Find variables in clique that are not in the neighbors
% % % In other words, these are the marginalized variables in the clique
% % % tree
neighbors = find(edges(bestNode,:));
varsEliminated = [];
for i = 1:length(neighbors)
    if neighbors ~= bestNode
        scope_neighbor = C.nodes{neighbors(i)};
        for j = 1:length(scope)
            if ~ismember(scope(j),scope_neighbor)
                varsEliminated = [varsEliminated,scope(j)];
            end
        end
    end
end

% % % Find all the factors that contain the eliminated variable
if ~isempty(varsEliminated)
    factorsCounted = [];
    for i = 1:length(varsEliminated)
        for j = 1:length(C.factorList)
            if ~ismember(j,removedFactors)
                if ismember(varsEliminated(i),C.factorList(j).var)
                    factorsCounted = [factorsCounted,j];
                end
            end
        end
    end
else
    factorsCounted = [];
    for j = 1:length(C.factorList)
        if ~ismember(j,removedFactors)
            for k = 1:length(scope)
                if ismember(scope(k),C.factorList(j).var)
                    factorsCounted = [factorsCounted,j];
                end
            end
        end
    end
end

% % % Find factors that are subset of scope of factors furthest away from
% % % the tree
for j = 1:length(C.factorList)
    if ~ismember(j,removedFactors)
        factor_var = C.factorList(j).var;
        numIntersect = sum(ismember(factor_var,scope));
        if numIntersect == length(factor_var)
            factorsCounted = [factorsCounted,j];
        end
    end
end

factors2Nodes = unique(factorsCounted);
removedFactors = [removedFactors,factorsCounted];
