function [avgStride,devStride,maxStride,count,finalStrides] = detectStrides(paw,stance,thresholdStride)

%% refine this function %%

stride = stance(:,1);

% Find all potential strides (events that exceed the stride time threshold)

strideStarts = [];
strideEnds   = [];

onTrail      = 0;

for n = 1:length(stride)

    if (stride(n) == 1 && ~isnan(paw(n,1))) && (stance(n,3) == 0)
        
        if onTrail == 0
            onTrail = 1;
            strideStarts = [strideStarts ; n];
        end
        
    else
        
        if onTrail == 1
            onTrail = 0;
            strideEnds = [strideEnds ; n-1];
        end
        
    end
    
end

finalStrides = [];

for n = 1:length(strideEnds)
    
    if (strideEnds(n) - strideStarts(n)) > thresholdStride
        
        finalStrides = [ finalStrides ; strideStarts(n) strideEnds(n) ];
        
    end
    
end

% now that we have all the potential strides marked...
% let's look them up and determine the stride length!

strideLengths = [];

if sum(sum(finalStrides)) > 0

    for n = 1:length(finalStrides(:,1))
    
        strideLength  = sqrt(((paw(finalStrides(n,1),1) - paw(finalStrides(n,2),1))^2) + ((paw(finalStrides(n,1),2) - paw(finalStrides(n,2),2))^2));
        strideLengths = [strideLengths ; strideLength];
    
    end

    maxStride = max(strideLengths);
    avgStride = nanmean(strideLengths);
    devStride = nanstd(strideLengths);
    count     = length(strideLengths);
else
    maxStride = NaN;
    avgStride = NaN;
    devStride = NaN;
    count     = 0;
end