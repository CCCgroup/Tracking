function limbclusters = assign_limbs(metaclusters)

centroids = zeros(4,2);

limbclusters = metaclusters;

for n = 1:4
    
    %if ~isempty(metaclusters(n).objects)
        centroids(n,:) = mean(metaclusters(n).objects(:,1:2));
    %else
    %    centroids(n,:) = [NaN NaN];
    %end
end

[~,indices] = sort(centroids(:,1),'descend'); % sort x coordinates (columns)... negative is caudal, 0 is rostral
temp        = centroids;

for n = 1:4
    limbclusters(n) = metaclusters(indices(n));
    centroids(n,:)  = temp(indices(n),:);
end


temp         = limbclusters;
[~,indices1] = sort(centroids(1:2,2));
[~,indices2] = sort(centroids(3:4,2));

for n = 1:2
    temp(n)   = limbclusters(indices1(n));
    temp(n+2) = limbclusters(indices2(n)+2);
end

temp(1).limb  = 'left front paw';
temp(2).limb  = 'right front paw';
temp(3).limb  = 'left hind paw';
temp(4).limb  = 'right hind paw';

limbclusters = temp;