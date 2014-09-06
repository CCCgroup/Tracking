% Alter function: first pass, separate front/hind limbs (x coordinates only)
%                 second pass, separate left/right front limbs (x and y coordinates)
%                 third pass, separate left/right hind limbs (x and y coordinates)

function [storage,the_key,stats] = progressive_kmeans(objects,clusters,samplesize)

storage = struct([]);
stats   = struct([]);
count   = 0;

% Can be refined: not the cleanest min and max values due to inclusion of
% 'noise objects' (often outliers)

objmin  = min(get_objects_from_structure(objects)); 
objmin  = objmin(1:3);

objmax  = max(get_objects_from_structure(objects));
objmax  = objmax(1:3);

for n = 1:samplesize:length(objects)
    
    if n > length(objects)
        break
    end
    
    % get the objects from a 100-frame subset
    if (n + (samplesize-1)) <= length(objects)
        obj = get_objects_from_structure(objects(n:(n+(samplesize-1))));
%         obj(:,1) = (obj(:,1) - objmin(1)) / (objmax(1) - objmin(1));
%         obj(:,2) = (obj(:,2) - objmin(2)) / (objmax(2) - objmin(2));
%         obj(:,3) = (obj(:,3) - objmin(3)) / (objmax(3) - objmin(3));
    else
        obj = get_objects_from_structure(objects(n:end));
%         obj(:,1) = (obj(:,1) - objmin(1)) / (objmax(1) - objmin(1));
%         obj(:,2) = (obj(:,2) - objmin(2)) / (objmax(2) - objmin(2));
%         obj(:,3) = (obj(:,3) - objmin(3)) / (objmax(3) - objmin(3));
    end
    
    %size(obj)
    if ~isempty(obj)
    
    obj(:,1) =  obj(:,1)      / 256; % 512
    obj(:,2) =  obj(:,2)      / 256;
    obj(:,3) = (obj(:,3) + 1) / 500;
    
    % FILTER OUT THE CRAP %
    % get rid of the tail base (mass = -1)
    indices        = obj(:,3);
    indices        = (indices == 0);
    obj(indices,:) = [];
    % get rid of the tail (largest object in every frame)
    startingframe = obj(1,4);
    for m = 1:samplesize
        temp   = obj(:,4);
        subset = obj(temp == (startingframe + m - 1),3);
        val = max(subset);
        [~,ind] = ismember(val, obj(:,3));
        obj(ind,:) = [];
    end
    % get rid of any objects that are too large (> 500 pixels)
    indices        = obj(:,3);
    indices        = (indices > 1);
    obj(indices,:) = [];
    
    % get rid of any objects that are too far left (centroid in first 33%
    % of frame
    indices        = obj(:,1);
    indices        = (indices < -0.67);
    obj(indices,:) = [];
    
    % classify the subset
    if clusters < length(obj(:,1:3))
    [classes,centroids]      = kmeans(obj(:,1:3),clusters,'Replicates',20);
    
    count                    = count + 1;
    storage(count).classes   = classes;
    storage(count).centroids = centroids;
    storage(count).objects   = obj;
    
    stats(count).objects     = obj;
    stats(count).classes     = classes;
    
    end
    else
        count                    = count + 1;
        storage(count).classes   = [];
        storage(count).centroids = [];
        storage(count).objects   = [];
        
        stats(count).objects     = [];
        stats(count).classes     = [];
        
    end
        
end

% get rid of clusters that are too small? (e.g. objects present in less 
% than 20% of frames?)

% create a cluster-matching array
the_key  = struct([]);
counting = 0;

% match clusters in "storage"
new_store = storage;

cluster_match_over_time = [];

for n = 2:length(storage)
    
    clusters1 = storage(n-1).centroids;
    clusters2 = storage(n).centroids;
    
    if (~isempty(clusters1) && ~isempty(clusters2))
    
    matchvals = zeros(clusters,2);
    
    % match storage entries n and n-1
    for q = 1:clusters
        
        currentcluster = clusters1(q,:);
        tempmatch      = clusters2;
        
        for iter = 1:clusters
            tempmatch(iter,:) = (clusters2(iter,:) - currentcluster).^2;
        end
        
        tempmatch = sum(tempmatch,2);
        [matchvals(q,2),matchvals(q,1)] = min(tempmatch);
        
    end
    
    counting                    = counting + 1;
    the_key(counting).matchvals = matchvals;
    the_key(counting).n         = n;
    
    %matchvals(:,1)
    %matchvals(:,2)
    
    cluster_match_over_time = [cluster_match_over_time ; n length(unique(matchvals(:,1)))];
%     
%     for q = 1:clusters
%         
%         if bestmatch(q,matchvals) 
%             new_store(n).centroids(q,:) = storage(n).centroids(matchvals(q,1),:);
%             new_store(n).classes(storage(n).classes == matchvals(q,1)) = q;
%             
%         else
%             new_store(n).centroids(q,:) = new_store(n).centroids(q,:)  * -1;
%             new_store(n).classes(storage(n).classes == matchvals(q,1)) = -1;
%         end
%         
%     end
    
    
    end
end

figure;
bar(cluster_match_over_time(:,1),cluster_match_over_time(:,2),'r')
ylabel('Number of matched clusters')
xlabel('Time slice number')
title('Matching clusters found during progressive K-means')