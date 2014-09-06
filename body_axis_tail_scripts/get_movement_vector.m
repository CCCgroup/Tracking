%
% motion = get_movement_vector(trace,threshold,interval)
%
% This function takes as input a position vector (trace) and uses a sliding
% window of 9 datapoints to estimate the average speed at that point. If
% the speed exceeds a certain value (threshold), the corresponding data
% points in the returned vector (motion) are set to 1. All other data
% points in the returned vector are NaN.
%
% In a second pass through the resulting vector, NaN values spanning a
% certain length (interval) or less between values of 1 are set to 1.
%
% NOTE: in case of noisy data, low-pass filtering can greatly improve the
% result.

function motion = get_movement_vector(trace,threshold,interval,filtwidth)

speed  = abs(diff(trace));

motion = NaN .* zeros(size(trace));

offset = round((filtwidth - 1) / 2);

for n = (offset+1):(length(speed)-offset)
    
    if mean(speed((n-offset):(n+offset))) > threshold
        motion(n:(n+1)) = 1;
    end
    
end

tracking = 0;
count    = 0;

for n = 1:length(motion)
    
    if n < (interval + 1)
        
        
    elseif n > (length(motion) - interval)
        
        
    else
        
        
        
        if isnan(motion(n))
            
            if tracking
                count = count + 1;
            end
            
            if count > interval
                tracking = 0;
                count    = 0;
            end
        else
            tracking = 1;
            
            if ((count < (interval + 1)) && (count ~= 0))
                motion((n-count):n) = 1;
            end
                
            count = 0;
         end
    end
end