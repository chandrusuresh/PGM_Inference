%GETNEXTCLIQUES Find a pair of cliques ready for message passing
%   [i, j] = GETNEXTCLIQUES(P, messages) finds ready cliques in a given
%   clique tree, P, and a matrix of current messages. Returns indices i and j
%   such that clique i is ready to transmit a message to clique j.
%
%   We are doing clique tree message passing, so
%   do not return (i,j) if clique i has already passed a message to clique j.
%
%	 messages is a n x n matrix of passed messages, where messages(i,j)
% 	 represents the message going from clique i to clique j. 
%   This matrix is initialized in CliqueTreeCalibrate as such:
%      MESSAGES = repmat(struct('var', [], 'card', [], 'val', []), N, N);
%
%   If more than one message is ready to be transmitted, return 
%   the pair (i,j) that is numerically smallest. If you use an outer
%   for loop over i and an inner for loop over j, breaking when you find a 
%   ready pair of cliques, you will get the right answer.
%
%   If no such cliques exist, returns i = j = 0.
%
%   See also CLIQUETREECALIBRATE
%
% Copyright (C) Daphne Koller, Stanford University, 2012


function [i, j] = GetNextCliques(P, messages)

% initialization
% you should set them to the correct values in your code
i = 0;
j = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ii = 1:size(messages,2)
    neighbors_1 = find(P.edges(:,ii));
    for jj = 1:length(neighbors_1)
        % % % If message is already passed, then skip
        if ~isempty(messages(neighbors_1(jj),ii).var)
            continue;
        end        
        neighbors_2 = find(P.edges(:,neighbors_1(jj)));
        status = zeros(length(neighbors_2),1);   
        for k = 1:length(neighbors_2)
            if neighbors_2(k) == ii
                continue;
            else
                if ~isempty(messages(neighbors_2(k),neighbors_1(jj)).var)
                    status(k) = 1;
                end                 
            end           
        end
        if length(find(status)) == length(neighbors_2)-1
            i = neighbors_1(jj);
            j = ii;
            return;
        end
    end
end