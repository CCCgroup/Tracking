function mouseBinned = binMouse_v2(frametimes,mouse)

mouseBinned = zeros(length(frametimes)-1,2);

% COMPLETE MOUSE PATH FIRST (NO GAPS) !!!

[mouse,~] = elimWraps_v2(mouse,0.05); % <-- instantaneous jumps of 0.05V or more are eliminated

for n = 1:length(frametimes)-1
    
    [~,loc1] = ismember(frametimes(n)  ,mouse(:,1));
    [~,loc2] = ismember(frametimes(n+1),mouse(:,1));
    
    if (loc1 > 0) && ((loc2 > 0) && (loc2 <= length(mouse(:,1))))
        mouseBinned(n,:) = mean(mouse(loc1:loc2,:));
    else
        if (n > 1) && (mouseBinned(n-1,1) > 0)
            mouseBinned(n,:) = mouseBinned(n-1,:);
        end
    end
    
end