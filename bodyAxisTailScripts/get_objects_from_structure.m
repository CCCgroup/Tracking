function [objects] = get_objects_from_structure(stuff)

objects = [];

for n = 1:length(stuff)
    
    if ~isempty(stuff(n).objects)
        q       = length(stuff(n).objects(1,:));
        objects = [objects [stuff(n).objects ; stuff(n).frame * ones(1,q)]];
    end
end

objects = objects';
%objnorm = objects;

% for n = 1:(length(objnorm(1,:))-1)
%     
%     objnorm(:,n) = objnorm(:,n) - min(objnorm(:,n));
%     objnorm(:,n) = objnorm(:,n) / max(objnorm(:,n));
%     
% end