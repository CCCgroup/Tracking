% This function takes all the analog signals from the disc experiment and
% reshapes them into several variables for two-photon frame times, disc
% position and -- in the future -- lick events.

function [frametimes,encoderPath, encode_w_frametimes] = processAnalogSignals(theData)

timeStamps = theData(:,1);
frameTTL   = theData(:,2);
discPos    = theData(:,3);
%lickData   = theData(:,4);

entries    = length(timeStamps);

% get the two-photon frame times

tracking   = 0;
frametimes = timeStamps(1);
encode_w_frametimes = discPos(1);

for n = 2:entries
    
    % gather frame times
    if frameTTL(n) > 4 %TTL ticks are above 4(V)
        
        % eliminate cross-talk effect on disc position trace (en passant)
        discPos(n) = discPos(n) - 0.012;
        
        if tracking == 0
            frametimes = [frametimes ; timeStamps(n)];
            encode_w_frametimes = [encode_w_frametimes; discPos(n)];
            tracking = 1;
        end
        
    else
        
        tracking = 0;
    
    end
    
end

encoderPath = [timeStamps(2:end) discPos(2:end)];
