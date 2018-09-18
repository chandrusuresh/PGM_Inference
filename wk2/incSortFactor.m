function Fnew = incSortFactor(F)

N = length(F);

Fnew = repmat(struct('var', [], 'card', [], 'val', []), N, 1);

for i = 1:N
    var = F(i).var;
    [sortedVar,I] = sort(var);
    Fnew(i).var = sortedVar;
    Fnew(i).card = F(i).card(I);
    Fnew(i).val = zeros(1,length(F(i).val));
    assignment = IndexToAssignment(1:prod(F(i).card),F(i).card);
    for j = 1:size(assignment,1)
        new_assignment = assignment(j,I);
        idx = AssignmentToIndex(new_assignment,Fnew(i).card);
        Fnew(i).val(idx) = F(i).val(j);
    end
end
    