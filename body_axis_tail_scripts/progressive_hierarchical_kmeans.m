function [storage,the_key] = progressive_hierarchical_kmeans(objects,samplesize,overlap,specs)

storage = struct([]);
count   = 0;

for n = 1:(samplesize-overlap):length(objects)
    %disp(['Starting point: ' int2str(n)])
    
    if n > length(objects)
        break
    end
    
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
    
    obj(:,1) =  obj(:,1)      /  256; % 512
    obj(:,2) =  obj(:,2)      /  128; % 256
    obj(:,3) = (obj(:,3) + 1) / 1000;
    
    % Add object property: distance to tail base
    obj = add_dist_from_tailbase(obj,specs);
        
    % FILTER OUT THE CRAP %
    % get rid of the tail base (mass = 0)
%     indices        = obj(:,3);
%     indices        = (indices == 0);
%     obj(indices,:) = [];
    % get rid of the tail (largest object in every frame)
%     startingframe = obj(1,4);
%     for m = 1:samplesize
%         temp   = obj(:,4);
%         subset = obj(temp == (startingframe + m - 1),3);
%         val = max(subset);
%         [~,ind] = ismember(val, obj(:,3));
%         obj(ind,:) = [];
%     end
    
    % get rid of any objects that are too large (> 1000 pixels)
    indices        = obj(:,3);
    indices        = (indices > 1);
    obj(indices,:) = [];
    
    % get rid of any objects that are too far left (centroid in first ~30%
    % of frame
    indices        = obj(:,1);
    indices        = (indices < -0.67);
    obj(indices,:) = [];
    
    % get rid of any objects that are too far up, or too far down
    indices        = obj(:,2);
    indices        = (abs(indices) > 1);
    obj(indices,:) = [];
    
    % get rid of any objects that are too close to the tail base
    indices        = obj(:,5);
    indices        = (indices < 0.15);
    obj(indices,:) = [];
    
%     figure;
%     plot(sort(obj(:,5)));
    
    % classify the subset
    if 4 < length(obj(:,1:3))
        
        % first pass: front/hind, x coords only (or add size or distance from tail?)
        
        success = 0;
        
        for clustpass = 1:1000
            [classes,cent] = kmeans(obj(:,1),2,'Replicates',20);
            
            % second pass: right/left, front or hind limbs only, x and y coords
            % (add area information?)
            obj1 = obj(classes == 1, :);
            obj2 = obj(classes == 2, :);
            
            if ((length(obj1(:,1)) > 1) && (length(obj2(:,1)) > 1))
                success = 1;
                break
            end
        end
        
        if ~success
            disp('After 1000 iterations, still no reliable front/hind limb separation.');
        end
        
        if length(obj1(:,1)) > 1
        [classes1,centroids1] = kmeans(obj1(:,2),2,'Replicates',20);
        %else
        %classes1 = 1;
        %centroids1 = obj1(1,2);
        else
            %disp('Empty @1')
            classes1   = [];
            centroids1 = [];
        end
        if length(obj2(:,1)) > 1
        [classes2,centroids2] = kmeans(obj2(:,2),2,'Replicates',20);
        %else
        %classes2 = 1;    
        %centroids2 = obj2(1,2);
        else
            %disp('Empty @2')
            classes2   = [];
            centroids2 = [];
        end
            
        obj       = [obj1 ; obj2];
        classes   = [classes1 ; (classes2 + 2)];
        centroids = [ones(size(centroids1)).*cent(1) centroids1 ; ones(size(centroids2)).*cent(2) centroids2];
        
        
%         figure
%         hold on
%         scatter(obj1(classes1 == 1,1),obj1(classes1 == 1,2),'r')
%         scatter(obj1(classes1 == 2,1),obj1(classes1 == 2,2),'g')
%         scatter(obj2(classes2 == 1,1),obj2(classes2 == 1,2),'b')
%         scatter(obj2(classes2 == 2,1),obj2(classes2 == 2,2),'k')
%         hold off
%         axis ij
%         title(['Hierarchical k-means for frames ' int2str(min(obj(:,4))) ' to ' int2str(max(obj(:,4)))])
        
    count                    = count + 1;
    storage(count).classes   = classes;
    storage(count).centroids = centroids;
    storage(count).objects   = obj;
    
    %stats(count).objects     = obj;
    %stats(count).classes     = classes;
    
    end
    else
        count                    = count + 1;
        storage(count).classes   = [];
        storage(count).centroids = [];
        storage(count).objects   = [];
        
        %stats(count).objects     = [];
        %stats(count).classes     = [];
        
    end
        
end

% get rid of clusters that are too small? (e.g. objects present in less 
% than 20% of frames?)

% create a cluster-matching array
the_key  = struct([]);
counting = 0;

% match clusters in "storage"
%new_store = storage;

%cluster_match_over_time = [];

for n = 2:length(storage)
    
    clusters1 = storage(n-1).centroids;
    clusters2 = storage(n).centroids;
    
    if (~isempty(clusters1) && ~isempty(clusters2))
    
    matchvals = zeros(4,2);
    
    % match storage entries n and n-1
    for q = 1:4
        
        currentcluster = clusters1(q,:);
        tempmatch      = clusters2;
        
        for iter = 1:4%length(clusters2(:,1)) %4
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
    
    %cluster_match_over_time = [cluster_match_over_time ; n length(unique(matchvals(:,1)))];
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

% figure;
% bar(cluster_match_over_time(:,1),cluster_match_over_time(:,2),'r')
% ylabel('Number of matched clusters')
% xlabel('Time slice number')
% title('Matching clusters found during progressive hierarchical K-means')