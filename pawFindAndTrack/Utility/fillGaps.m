function result = fillGaps(trace,maxGapSize)

result = trace;

for n = 1:length(trace)
    
    if isnan(result(n))
        
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
                if isnan(result(n-start))
                else
                    loc1   = n-start;
                    found1 = 1;
                end
            end
            
            % if next not found
            if found2 == 0
                finish = finish + 1;
                if (n + finish) > length(result)
                    loc2   = length(result);
                    finish = finish - 1;
                    found2 = 1;
                end
                if isnan(result(n+finish))
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
        
        if isnan(result(loc1)) || isnan(result(loc2))
            % nevermind
        else
            % use loc1 and loc2 for some fierce interpolation!
            dist1 = loc2 - loc1;
            dist2 = loc2 - n;
            
            if dist1 < maxGapSize
                result(n) = ((dist2 / dist1) * result(loc1)) + (((dist1 - dist2)/dist1) * result(loc2));
            end
            
            % BOOYAH!
            
        end
        
    end
    
end