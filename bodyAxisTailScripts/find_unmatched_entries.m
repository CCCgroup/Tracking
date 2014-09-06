function unmatched = find_unmatched_entries(matched,iter)

unmatched = [];

for n = 1:iter
    
    % check to see if all four clusters are present at n
    entries = matched(matched(:,1) == n,:);
    
    for q = 1:4
        if ~ismember(q,entries(:,2))
            unmatched = [unmatched ; n q NaN];
        end
        
        if ~ismember(q,entries(:,3))
            unmatched = [unmatched ; n NaN q];
        end
    end
end