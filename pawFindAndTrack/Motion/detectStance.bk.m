function stance = detectStance(pawCoords,mouse)

% IF NECESSARY: INCLUDE OPTICAL MOUSE DATA FOR MOVEMENT Y/N


paw       = pawCoords(:,1);                  % we need only x direction data

stanceDir = -1 .* sign(diff(mouse));         % direction of 'stance' movement as dictated by disc movement

stance    = zeros(length(paw),3);            % binary stance data + some sort of certainty measure + disc possibly not moving


%% interpolation for NaN values in pawCoords
for n = 2:length(stance)
    
    if isnan(pawCoords(n,1))
        
        % find closest previous non-NaN value, if it exists
        % find closest next non-NaN value, if it exists
        
        start  = 0;
        finish = 0;
        
        found1 = 0;
        found2 = 0;
        
        while (1)
            
            % if previous not found
            if found1 == 0
                start = start + 1;
                if (n - start) < 1
                    loc1   = 1;
                    start  = start - 1;
                    found1 = 1;
                end
                if isnan(paw(n-start))
                else
                    loc1   = n-start;
                    found1 = 1;
                end
            end
            
            % if next not found
            if found2 == 0
                finish = finish + 1;
                if (n + finish) > length(paw)
                    loc2   = length(paw);
                    finish = finish - 1;
                    found2 = 1;
                end
                if isnan(paw(n+finish))
                else
                    loc2   = n+finish;
                    found2 = 1;
                end
            end
            
            % if both found
            if found1 && found2
                break
            end
            
        end
        
        if isnan(paw(loc1)) || isnan(paw(loc2))
            % nevermind
        else
            % use loc1 and loc2 for some fierce interpolation!
            dist1 = loc2 - loc1;
            dist2 = loc2 - n;
            
            paw(n) = ((dist2 / dist1) * paw(loc1)) + (((dist1 - dist2)/dist1) * paw(loc2));
            
            % BOOYAH!
            
        end
        
    end
    
end

xDir      = diff(paw);  % direction of movement per time bin

%% detection of stance
for n = 2:length(stance)
    
    % detect direction by averaging sign of 5 datapoints before and after
    % (if possible, that is)
    if ((n-5) < 1)
        pos1 = 1;
    else
        pos1 = n-5;
    end
    
    if ((n+4) > length(xDir))
        pos2 = length(xDir);
    else
        pos2 = n+4;
    end
    
    direction = mean(xDir(pos1:pos2));
    
    % if sign of stanceDir: stance
    if (sign(direction) == stanceDir(n))
        
        stance(n,1) = 1;
        stance(n,2) = direction;
    
    % if disc not moving: stance

    else if  (abs(diff(mouse(n-1:n,1))) < 0.5)
            
            stance(n,1) = 1;
            stance(n,2) = direction;
            stance(n,3) = 1;
        
        % else: swing
        else
            stance(n,2) = direction;
        end
    end
    
end