function [avgDist,maxDist] = detectDistances(trace1,trace2)

maxDist = 0;

dists   = [];

for n = 1:length(trace1(:,1))
    
    if (trace1(n,1) == 0)
        trace1(n,:) = NaN .* trace1(n,:);
    end
    
    if (trace2(n,1) == 0)
        trace2(n,:) = NaN .* trace2(n,:);
    end
    
end

for n = 1:length(trace1(:,1))
    
    dist    = sqrt( ((trace1(n,1) - trace2(n,1))^2) + ((trace1(n,2) - trace2(n,2))^2) );
        
    if isnan(dist)
    else
        maxDist = max([dist maxDist]);
        dists   = [dists ; dist];
    end
        
end

avgDist = mean(dists);