function filteredTrace = qnd_filter_trace(trace,radius)

filteredTrace = trace;

if (length(trace) < (2 * radius + 1))
else

    for n = (radius + 1):(length(trace) - radius)
    
        filteredTrace(n) = nanmean(trace((n - radius):(n + radius)));
    
    end

end