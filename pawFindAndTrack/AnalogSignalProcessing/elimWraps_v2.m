function [mouseMove,wrapAroundsX] = elimWraps_v2(mousePath,jumpSize)

mouseMove     = zeros(max(mousePath(:,1)) - min(mousePath(:,1)),2) * NaN;
wrapAroundsX  = [];

offsetVal     = min(mousePath(:,1))-1;

for n = 2:length(mousePath(:,1))
    
    if (sqrt((mousePath(n,2) - mousePath(n-1,2))^2) > jumpSize)
        wrapAroundsX = [wrapAroundsX n];
        % eliminate wrap-around result
        if (mousePath(n,2) > mousePath(n-1,2))
            mousePath(1:n-1,2) = mousePath(1:n-1,2) + (mousePath(n,2) - mousePath(n-1,2));
        else
            mousePath(n:end,2) = mousePath(n:end,2) + (mousePath(n-1,2) - mousePath(n,2));
        end
    end
end

for n = 2:length(mousePath(:,1))
    
    if (mousePath(n,1) - mousePath(n-1,1) > 1)
        % time for some interpolation!
        distanceT = mousePath(n,1) - mousePath(n-1,1);
        distanceX = mousePath(n,2) - mousePath(n-1,2);
  
        if distanceX > 0
           traceX = mousePath(n-1,2):(distanceX / distanceT):mousePath(n,2);
        else
           traceX = ones(1,distanceT + 1) .* mousePath(n,2);
        end
                
        traceT = mousePath(n-1,1):mousePath(n,1);
           
        mouseMove((mousePath(n,1)-offsetVal)-distanceT:(mousePath(n,1)-offsetVal),:) = [traceT ; traceX]';
        
    else
        % just store the data point already!
        mouseMove((mousePath(n,1)-offsetVal),:) = mousePath(n,:);
    end
    
end

mouseMove(1,:) = mousePath(1,:);