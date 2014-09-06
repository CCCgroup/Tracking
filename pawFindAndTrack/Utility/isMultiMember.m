function [bool,indices] = isMultiMember(element,array)

indices = [];

while length(array) > 0;
    
    [~,loc] = ismember(element,array);
    
    if loc ~= 0

        indices = [indices loc];
    
    end
    
    array = array(1:end-1);
    
end

indices = unique(indices);

if length(indices) > 1
    
    bool = 1;
    
else
    
    bool = 0;
    
end