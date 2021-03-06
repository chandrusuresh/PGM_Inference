%CLIQUETREECALIBRATE Performs sum-product or max-product algorithm for 
%clique tree calibration.

%   P = CLIQUETREECALIBRATE(P, isMax) calibrates a given clique tree, P 
%   according to the value of isMax flag. If isMax is 1, it uses max-sum
%   message passing, otherwise uses sum-product. This function 
%   returns the clique tree where the .val for each clique in .cliqueList
%   is set to the final calibrated potentials.
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function P = CliqueTreeCalibrate(P, isMax)


% Number of cliques in the tree.
N = length(P.cliqueList);

% Setting up the messages that will be passed.
% MESSAGES(i,j) represents the message going from clique i to clique j. 
MESSAGES = repmat(struct('var', [], 'card', [], 'val', []), N, N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% We have split the coding part for this function in two chunks with
% specific comments. This will make implementation much easier.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% YOUR CODE HERE
% While there are ready cliques to pass messages between, keep passing
% messages. Use GetNextCliques to find cliques to pass messages between.
% Once you have clique i that is ready to send message to clique
% j, compute the message and put it in MESSAGES(i,j).
% Remember that you only need an upward pass and a downward pass.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P1 = P;
if isMax
    for i = 1:length(P.cliqueList)
        P1.cliqueList(i).val = log(P.cliqueList(i).val);
    end
end

totalUpstreamMsgs = sum(sum(P1.edges));
msgCount = 0;
while msgCount < totalUpstreamMsgs
    [i,j] = GetNextCliques(P1, MESSAGES);
    neighbors_1 = find(P1.edges(:,i));
    MESSAGES(i,j) = P1.cliqueList(i);
    for k = 1:length(neighbors_1)
        if neighbors_1(k) ~= j
            if ~isempty(MESSAGES(i,j).var)
                if ~isMax
                    MESSAGES(i,j) = FactorProduct(MESSAGES(i,j),MESSAGES(neighbors_1(k),i));
                    MESSAGES(i,j).val = MESSAGES(i,j).val/sum(MESSAGES(i,j).val);
                else
                    MESSAGES(i,j) = FactorSum(MESSAGES(i,j),MESSAGES(neighbors_1(k),i));
                end
            end
        end
    end
    sepSet = intersect(P1.cliqueList(i).var,P1.cliqueList(j).var);
    summedOutVars = setdiff(P1.cliqueList(i).var,sepSet);
    if ~isMax
        MESSAGES(i,j) = FactorMarginalization(MESSAGES(i,j), summedOutVars);
        MESSAGES(i,j).val = MESSAGES(i,j).val/sum(MESSAGES(i,j).val);
    else
        MESSAGES(i,j) = FactorMaxMarginalization(MESSAGES(i,j), summedOutVars);
    end
    msgCount = msgCount + 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% Now the clique tree has been calibrated. 
% Compute the final potentials for the cliques and place them in P1.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
final_potential = P1.cliqueList;
for i = 1:length(P1.cliqueList)
    neighbors = find(P1.edges(:,i));
    for j = 1:length(neighbors)
        if ~isMax
            final_potential(i) = FactorProduct(final_potential(i),MESSAGES(neighbors(j),i));
        else
            final_potential(i) = FactorSum(final_potential(i),MESSAGES(neighbors(j),i));
        end
    end
end
P1.cliqueList = final_potential;
P = P1;
return
