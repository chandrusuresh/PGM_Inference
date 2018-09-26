% FactorMaxMarginalization Max-marginalizes a factor 
% by taking the max over a given set variables.
% 
%   B = FactorMaxMarginalization(A,V) computes the factor with the variables
%   in V maxed out. The factor data structure has the following fields:
%       .var    Vector of variables in the factor, e.g. [1 2 3]
%       .card   Vector of cardinalities corresponding to .var, e.g. [2 2 2]
%       .val    Value table of size prod(.card)
%
%   B.var will be A.var minus V.
%   For each assignment in B, its value is the maximum value in A 
%   of all assignments in A consistent with that assignment in B.
%
%   The resultant factor should have at least one variable remaining or this
%   function will throw an error.
%
%   This is exactly the same as FactorMarginalization, 
%   but with the sum replaced by a max.
% 
%   See also FactorMarginalization.m, IndexToAssignment.m, and AssignmentToIndex.m
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function B = FactorMaxMarginalization(A, V)

% Check for empty factor or variable list
if (isempty(A.var) || isempty(V)), B = A; return; end;

% Construct the output factor over A.var \ V (the variables in A.var that are not in V)
% and mapping between variables in A and B
[B.var, mapB] = setdiff(A.var, V);

% Check for empty resultant factor
if isempty(B.var)
  error('Error: Resultant factor has empty scope');
end;

% initialization
% you should set them to the correct values in your code
B.card = A.card(mapB);
B.val = [];%zeros(1,prod(B.card));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
% Correctly set up and populate the factor values of B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
assignment_A = IndexToAssignment(1:prod(A.card),A.card);
assignment_B = IndexToAssignment(1:prod(B.card),B.card);

indices = [];
for i = 1:size(assignment_B,1)
    assgn_B = assignment_B(i,:);
    for j = 1:size(assignment_A,1)
        ind = find(indices == j);
        % % % Do not look into indices already searched
        if isempty(ind)
            assgn_A = assignment_A(j,mapB);
            if sum(assgn_B-assgn_A) == 0
                % % % Track indices searched.
                indices = [indices,j];
                % % % Thought elegant way is to preallocate B.val to zeros
                % % % Turns out the test case had negative potentials.
                % % % This if-else loop structure takes care of that.
                if isempty(B.val)
                    B.val(i) = A.val(j);
                elseif length(B.val) >= i
                    if A.val(j) > B.val(i)
                        B.val(i) = A.val(j);
                    end
                else
                    B.val(i) = A.val(j);
                end
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

