function [objmatch,clusters] = match_clustered_objects(stor,proc,old)

temp     = stor;
objmatch = [];

for n = 1:length(stor)
    
    if ~isempty(stor(n).objects)
        temp(n).objects(:,1)     =  stor(n).objects(:,1) * 256;
        temp(n).objects(:,2)     =  stor(n).objects(:,2) * 128;
        temp(n).objects(:,3)     = (stor(n).objects(:,3) * 1000) - 1;
        temp(n).objects(:,4)     =  stor(n).objects(:,4) - 1;
%         temp(n).objects(:,5:end) = [];
%         temp(n).objects          = [temp(n).objects zeros(length(temp(n).objects(:,1)),1)];
    end
end

for n = 1:length(temp)
    
    if ~isempty(temp(n).objects)
        for q = 1:length(temp(n).objects(:,1))
            
            current    = temp(n).objects(q,1:4);
            %current(4) = current(4) - 1;
            
            [tf,ind] = ismember(current(1:3),proc(current(4)).objects(1:3,:)','rows');
            
            if tf
                objmatch = [objmatch ; old(current(4)).objects(:,ind)' current(4) n];
            end
        end
    end
end

% replace temp object arrays with original objects...

clusters = temp;
for n = 1:4
clusters(n).objects = [];
end

for n = 1:length(objmatch(:,1))
    
    clusters(objmatch(n,5)).objects = [clusters(objmatch(n,5)).objects ; objmatch(n,1:4)];
    
end