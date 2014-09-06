function cleanTrace = cleanuptrace(trace,threshold)

cleanTrace = trace;

for n = 2:length(trace(:,1))-1
    
    if abs(trace(n,1) - trace(n-1,1)) > threshold
        if isnan(trace(n+1,1))
            cleanTrace(n,:) = trace(n,:) .* NaN;
        else if abs(trace(n,1) - trace(n+1,1)) > threshold
                cleanTrace(n,:) = trace(n,:) .* NaN;
            end
        end
    end
end