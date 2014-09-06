function newobj = add_dist_from_tailbase(obj,specs)

newobj = [obj zeros(length(obj(:,1)),1)];

% assumes data is normalized and tailbase objects have a mass of <= 0
for n = 1:length(obj(:,1))
    
    %if (obj(n,3) <= 0)
        
    frame       = obj(n,4);
    xy          = obj(n,1:2);
    
    newobj(n,5) = sqrt( ((xy(1) - specs(frame,1))^2) + ((xy(2) - specs(frame,2))^2) );
        
%     [tf, ind] = isMultiMember(frame,obj(:,4));
%         
%     if tf
%     for q = 1:length(ind)
%         
%         x = obj(ind(q),1);
%         y = obj(ind(q),2);
%             
%         newobj(ind(q),5) = sqrt( ((xy(1) - x)^2) + ((xy(2) - y)^2) );
%             
%     end
%     end
    %end
    
end