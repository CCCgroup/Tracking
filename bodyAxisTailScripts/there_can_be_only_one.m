function newobjects = there_can_be_only_one(oldobjects)

newobjects = [];

fr_0 = min(oldobjects(:,4));
fr_n = max(oldobjects(:,4));
 
for n = fr_0:fr_n
    
    current_frame = oldobjects(oldobjects(:,4) == n, :);
    dims = size(current_frame);
    
    if dims(1) > 1
        
        bestcandidate = [0 0];
        
        for q = 1:dims(1)
            
            [~,Px] = ttest2(oldobjects(:,1),current_frame(q,1));
            [~,Py] = ttest2(oldobjects(:,2),current_frame(q,2));
            P = Px * Py;
            
            if P > bestcandidate(1)
                bestcandidate = [P q];
            end
            
        end
        
        newobjects = [newobjects ; current_frame(bestcandidate(2),:)];
        
    else
        newobjects = [newobjects ; current_frame];
    end
    
end