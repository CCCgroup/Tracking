function [tf,val] = majority(theSet)

checkedValues = [];

tempVal       = [];

for n = 1:length(theSet)
    
    if ismember(theSet(n),checkedValues)
    else
        checkedValues = [checkedValues ; theSet(n)];
        [~,indices]   = isMultiMember(theSet(n),theSet);
        part          = length(indices) / length(theSet);
        tempVal       = [tempVal ; theSet(n) part];
    end
    
end

[part,indices] = max(tempVal(:,2));

if isMultiMember(part,tempVal(:,2))
    tf  = 0;
    val = 0;
else
    tf  = 1;
    val = tempVal(indices,1);
end