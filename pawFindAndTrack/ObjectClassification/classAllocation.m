function finalTraces = classAllocation(newTraces,resultFinal)

finalTraces = newTraces;

for n = 1:length(finalTraces)
    
    if (finalTraces{n}.class == 0)
        [~,loc]              = max(resultFinal(:,n));
        finalTraces{n}.class = loc;
    end
    
end