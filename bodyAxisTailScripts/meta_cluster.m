function metaclusters = meta_cluster(filtdat,store)

metaclusters = struct([]);

% determine samplesize
samplesize = 0;
for n = 1:length(store)
    if ~isempty(store(n).objects)
        range = [min(store(n).objects(:,4)) max(store(n).objects(:,4))];
        if (range(2) - range(1) + 1) > samplesize
            samplesize = range(2) - range(1) + 1;
        end
    end
end

% bin filtdat to samplesize specifications
binned_dat = [];
for n = 1:samplesize:length(filtdat)
    
    if n > length(filtdat)
        break
    elseif (n + samplesize - 1) > length(filtdat)
        
        % how many entries left?
        q = length(filtdat) - n;
        
        if sum(isnan(filtdat(n:(n+q)))) == (q+1)
            binned_dat = [binned_dat ; 0 n];
        else
            binned_dat = [binned_dat ; 1 n];
        end
    else
        if sum(isnan(filtdat(n:(n+samplesize-1)))) == samplesize
            binned_dat = [binned_dat ; 0 n];
        else
            binned_dat = [binned_dat ; 1 n];
        end
    end
end

% based on filtdat and samplesize, determine the number of episodes for cluster matching
tracking = 0;
episodes = struct([]);
count    = 0;
for n = 1:length(binned_dat)
    
    if binned_dat(n,1)
        if ~tracking
            tracking              = 1;
            count                 = count + 1;
            episodes(count).start = binned_dat(n,2);
        end
    else
        if  tracking
            tracking              = 0;
            episodes(count).end   = binned_dat(n-1,2) + samplesize - 1;
        end
    end
end

if binned_dat(n,1)
    episodes(count).end = binned_dat(n,2) + samplesize - 1;
end

% per episode, match clusters from store
cluster_match = struct([]);

for n = 1:length(episodes)
    
    first = episodes(n).start;
    last  = episodes(n).end;
    
    cluster_match(n).centroids = [];
    cluster_match(n).objects   = [];
    
    for q = 1:length(store)
        
        if ~isempty(store(q).objects)
        early = min(store(q).objects(:,4));
        late  = max(store(q).objects(:,4));
        
        if ((early >= first) && (late <= last))
            cluster_match(n).centroids = [cluster_match(n).centroids ; store(q).centroids, (q * ones(4,1))];
            cluster_match(n).objects   = [cluster_match(n).objects   ; store(q).objects store(q).classes (q * ones(length(store(q).objects(:,1)),1))];
        end
        end
    end
    
    if ~isempty(cluster_match(n).centroids)

        episode = mix_and_match_clusters(cluster_match(n));
        
    end
    
    episodes(n).temp_clust = episode;
    
end

%finalclusters = episodes;

% align clusters so that they match best across episodes

align_map      = zeros(length(episodes),4);
align_map(1,:) = [1 2 3 4];
objects        = ([]);
objects(1).stuff = episodes(1).temp_clust(1).cluster;
objects(2).stuff = episodes(1).temp_clust(2).cluster;
objects(3).stuff = episodes(1).temp_clust(3).cluster;
objects(4).stuff = episodes(1).temp_clust(4).cluster;

size(episodes(1).temp_clust(1).cluster)
size(episodes(1).temp_clust(2).cluster)
size(episodes(1).temp_clust(3).cluster)
size(episodes(1).temp_clust(4).cluster)

for n = 2:length(episodes)
    
    prev_match = align_map(n-1,:);
    if sum(ismember(0,prev_match)) > 1
        disp('Forget it: matches too poor.')
        break
%     elseif sum(ismember(0,prev_match)) == 1
%         disp('Fixing poor match...')
%         abc = ismember(1:4,prev_match);
%         [~,ind0] = ismember(0,abc);
%         [~,indX] = ismember(0,prev_match);
%         prev_match(indX) = ind0;
    %else
        %disp('Matches are good...')
    end
    
    temp  = episodes(n-1).temp_clust;
    temp1 = temp;
    
    for q = 1:4
        if (prev_match(q) > 0)
        temp1(q) = temp(prev_match(q));
        end
    end
    
    temp2 = episodes(n  ).temp_clust;
    
    centroids1 = zeros(4,2);
    centroids2 = zeros(4,2);
    
    for q = 1:4
        centroids1(q,:) = mean(temp1(q).cluster(:,1:2));
        if ~isempty(temp2(q).cluster)
            centroids2(q,:) = mean(temp2(q).cluster(:,1:2));
        else
            centroids2(q,:) = NaN;
        end
    end
    
    distances = zeros(4);
    
    for q = 1:4
        for p = 1:4
            distances(p, q)  = sqrt( sum( (centroids1( q,:) - centroids2(p,:)) .^2 ) );
        end
    end
    
    % match the centroids
    for q = 1:4
        
        [~,ind1] = min(distances(:, q));
        [~,ind2] = min(distances(ind1,:));
        
        if (ind2 ==  q)
            align_map(n, q) = ind1;
            objects(q).stuff = [objects(q).stuff ; temp2(ind1).cluster];
        end
        
    end
    
end

% plot results for visual inspection

figure;

hold on

symbols = {'k', '+r', 'db', 'sg'};

for q = 1:4
    the_string = symbols{q};
    if ~isempty(objects(q).stuff)
        coordsX    = objects(q).stuff(:,1);
        coordsY    = objects(q).stuff(:,2);
        sizesXY    = 100;
        scatter(coordsX, coordsY, sizesXY, the_string);
    end
end

hold off
axis ij

title('Clustering result...')

% assign labels: "front", "hind", "left", "right"

% centroids = zeros(4,2);
% for q = 1:4
%     centroids(q,:) = mean(objects(q).stuff(:,1:2));
% end

% % front/hind
% [~,indices] = sort(centroids(:,1));
% 
% % left/right
% [~,rl_hind]  = sort(centroids(indices(1:2),2));
% [~,rl_front] = sort(centroids(indices(3:4),2));

for q = 1:4
    
    %[~,ind] = ismember(q,indices);
    
    %metaclusters(q).objects = there_can_be_only_one(objects(ind).stuff);
    metaclusters(q).objects = there_can_be_only_one(objects(q).stuff);
%     if ind > 2
%         
%         if ((rl_front(1) + 2 )== q)
%             metaclusters(q).limb = 'right front paw';
%         else
%             metaclusters(q).limb = 'left front paw';
%         end
%     else
%         if ((rl_hind(1)) == q)
%             metaclusters(q).limb = 'right hind paw';
%         else
%             metaclusters(q).limb = 'left hind paw';
%         end
%     end
end

assignin('base','metaclusters',metaclusters);
metaclusters = assign_limbs(metaclusters);
assignin('base','metaclusters',metaclusters);

