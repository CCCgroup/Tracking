function filtereddata = get_locomotion_frames(bufferready,motiontimes)

filtereddata = bufferready;

for n = 1:length(bufferready)
    
    % does this bufferReady frame overlap with a motiontimes entry?
    if ~(sum(ismember(bufferready(n):(bufferready(n)+9),motiontimes)) > 0)
        
        % if it doesn't, delete this entry...
        filtereddata(n) = NaN;
        
    end
    
end