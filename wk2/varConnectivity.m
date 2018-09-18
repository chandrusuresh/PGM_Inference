function [nodeAdj,factorAdj] = varConnectivity(nodes,factor)
    varCount = [];
    for i = 1:length(nodes)
        varCount = union(varCount,nodes{i});
    end
    nodeAdj = zeros(length(varCount),length(nodes));
    for i = 1:length(nodes)
        for j = 1:length(nodes{i})
        	nodeAdj(nodes{i}(j),i) = 1;
        end
    end
    factorAdj = zeros(length(varCount),length(factor));
    for i = 1:length(factor)
        for j = 1:length(factor(i).var)
        	factorAdj(factor(i).var(j),i) = 1;
        end
    end
end