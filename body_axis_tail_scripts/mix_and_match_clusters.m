function episode = mix_and_match_clusters(cluster_match)

centroids = cluster_match.centroids;
objects   = cluster_match.objects;

ep_range  = unique(centroids(:,3));

matches   = struct([]);
episode   = struct([]);

for n = 2:length(ep_range)
    
      object_indices1 = (objects(:,7) == ep_range(n-1));
      object_indices2 = (objects(:,7) == ep_range(n));
      
    current_objects1  = objects(object_indices1,:);
    current_objects2  = objects(object_indices2,:);
    
    % get the real centroids (i.e. xys, from object classification)
    real_centroids1   = zeros(4,3);
    real_centroids2   = zeros(4,3);
    
    objects1 = struct([]);
    objects2 = struct([]);
    
    for q = 1:4
        
        objects1(q).clustered = current_objects1(current_objects1(:,6) == q,1:4);
        objects2(q).clustered = current_objects2(current_objects2(:,6) == q,1:4);
        
        real_centroids1(q,:) = mean(objects1(q).clustered(:,1:3));
        real_centroids2(q,:) = mean(objects2(q).clustered(:,1:3));
        
    end
    
    % determine cluster overlap (are there duplicate objects?)
    overlapmap = zeros(4,4);
    
    for q = 1:4
        
        for h = 1:4
            
            x_match = ismember(objects1(q).clustered(:,1),objects2(h).clustered(:,1));
            y_match = ismember(objects1(q).clustered(:,2),objects2(h).clustered(:,2));
            s_match = ismember(objects1(q).clustered(:,3),objects2(h).clustered(:,3));
            
           xy_match = (x_match ==  y_match);
        total_match = (s_match == xy_match);
            
            overlapmap(q,h) = sum(total_match);
            
        end
    end
    
    matches(n-1).overlapmap = overlapmap;
    matches(n-1).objects1   = objects1;
    matches(n-1).objects2   = objects2;
    
end

% episode = matches;

% go through the matches structure to finalize the clustering
matched_clusters = [];

for n = 1:4
    
    currentIndex = n;
    
    tempObjects = [];
    
    for q = 1:length(matches)
        
        [val,ind]        = max(matches(q).overlapmap(currentIndex,:));
        
        % add check to see if this solution is unique? (i.e. best match?)
        [val_check,ind_check] = max(matches(q).overlapmap(:,ind));
        if ((val_check == val) && (ind_check == currentIndex))
        
        if sign(val)
            
            if ~isempty(matches(q).objects1(currentIndex).clustered)
                match1_temp      = matches(q).objects1(currentIndex).clustered;
            else
                match1_temp = [];
            end
            if ~isempty(matches(q).objects2(ind).clustered)
                match2_temp      = matches(q).objects2(ind).clustered;
            else
                match2_temp = [];
            end
         
            tempObjects      = [tempObjects ; match1_temp ; match2_temp];
            matched_clusters = [matched_clusters ; q currentIndex ind];
            currentIndex     = ind;
            
%             if (n == 1)
%             figure
%             hold on
%             scatter(match1_temp(:,1),match1_temp(:,2),'+k')
%             scatter(match2_temp(:,1),match2_temp(:,2),'r')
%             hold off
%             title(['Cluster #' int2str(n) ', match entry #' int2str(q)])
%             end
            
        else
            %disp('Dropping: no match found.')
            break;
        end
        else
            %disp('Dropping: non-unique match.')
            break;
        end
        
    end
    
    episode(n).cluster = tempObjects;
    
end

% based on the matched_clusters entries, determine the unmatched entries
unmatched = find_unmatched_entries(matched_clusters,length(matches));

% make all objects in the clusters unique
for n = 1:4
    if ~isempty(episode(n).cluster)
    %disp('---')
    %size(episode(n).cluster)
    episode(n).cluster = delete_doubles(episode(n).cluster);
    %size(episode(n).cluster)
    %disp('&&&')
    else
        %disp('No double entries: empty cluster!')
    end
    
end

% go through the unmatched clusters one by one and find the best matching
% cluster centroid



if ~isempty(unmatched)
    
temp_episode = episode;
    
for n = 1:length(unmatched(:,1))
    
    % get the unmatched objects (i.e. the cluster)
    if isnan(unmatched(n,2)) % take objects2
        temp = matches(unmatched(n,1)).objects2(unmatched(n,3));
    else                     % take objects1
        temp = matches(unmatched(n,1)).objects1(unmatched(n,2));
    end
    
    %temp.clustered
    
    % determine the cluster centroid and standard deviation
    %temp_centroid = mean(temp(:,1:3));
    %temp_spread   =  std(temp(:,1:3));
    
    for k = 1:length(temp.clustered(:,1))
        
        P = zeros(4,3);
        
        for q = 1:4
%         q
%         size(episode(q).cluster)
%         size(temp.clustered)
            if ~isempty(episode(q).cluster)
                [~,P(q,:)] = ttest2(episode(q).cluster(:,1:3),temp.clustered(k,1:3));
            else
                P(q,:) = NaN;
            end
        end
        
        
    temp_p = P(:,1) .* P(:,2) .* P(:,3);
    [~,best_match] = max(temp_p);
    %best_match
    %temp.clustered
    %size(temp_episode(best_match))
    temp_episode(best_match).cluster = [temp_episode(best_match).cluster ; temp.clustered(k,:)];
        
    end
    
end

% make all objects in the clusters unique
for n = 1:4
    if ~isempty(temp_episode(n).cluster)
        temp_episode(n).cluster = delete_doubles(temp_episode(n).cluster);
    end
end
episode = temp_episode;
end
