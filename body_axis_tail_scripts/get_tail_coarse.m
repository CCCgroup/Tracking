function [tailfits,bodyfits,tailangle,bodyangle,objects,rotatedobjects,intersects] = get_tail_coarse(folder,theta,firstframe,lastframe,headloc)

oldDir = cd;
cd(folder);

tiffs = dir('*.tif');

l = length(firstframe:lastframe);

template_set_size = round(0.05 * l); % 5% of the first objects taken around the median should be adequate tail representations
% if not: improve the quality of the data. 
% Shit in == shit out.

scorescape_mean = zeros(l,template_set_size);
scorescape_min  = zeros(l,template_set_size);

if isempty(strfind(tiffs(1).name,'backImg.tif'))
    onset = 0;
else
    onset = 1;
end

tail_est = zeros(l,2);
obj = {};

% detect the objects, 
% noting -per frame- the first (leftmost's): mass
disp('Object detection in progress...')

h    = waitbar(0,'Tail extraction in progress. Please wait..');
l    = length((firstframe+onset):(lastframe+onset));

the_count = 0;

for n = (firstframe+onset):(lastframe+onset)
    
    waitbar(n/l)
    
    if (n == firstframe + onset)
        disp(['First frame is ' tiffs(n).name])
    end
    
    % load image
    img = imread(tiffs(n).name);
    img = double(img);
    img = medfilt2(img);
    img = img ./ max(max(img));
      
    % threshold
    img(img < theta(1)) = 0;
    img(img > theta(2)) = 0;
    img = sign(img);
    img = im2bw(img,0.5);
    
    % make connectivity map (8 neighbors)
    conn = bwconncomp(img,8);
    
    the_count             = the_count + 1;
    obj{the_count}        = regionprops(conn,'PixelList');
    temp = struct([]);
    bip = 0;
    % filter out objects that are too small (< 40 pixels)
    for q = 1:length(obj{the_count})
        if length(obj{the_count}(q).PixelList(:,1)) < 40
        else
            bip                 = bip + 1;
            temp(bip).PixelList = obj{the_count}(q).PixelList;
        end
    end
    
    obj{the_count} = temp;
    
    if ~isempty(obj{the_count})
        tail_est(the_count,1) = length(obj{the_count}(1).PixelList(:,1));
        tail_est(the_count,2) = mean(obj{the_count}(1).PixelList(:,1));
    else
        tail_est(the_count,1) = NaN;
        tail_est(the_count,2) = NaN;
    end

end

objects    = obj;
intersects = nan(length(obj),2);

close(h);

disp('Calculating tail axis estimates...')

tailfits = nan(l,2);
bodyfits = nan(l,2);

tailangle = nan(l,1);
bodyangle = nan(l,1);

rotatedobjects = objects;

for n = 1:length(objects)
    
    if ~isempty(objects{n})
        
        temp = objects{n}(1).PixelList;
        
        tailfits(n,:) = polyfit(temp(:,1),temp(:,2),1); % fit straight line through tail
    end
end

disp('Performing body axis rotational correction...')

for n = 1:length(objects)
    
    if ~isempty(objects{n})
        
        temp = objects{n}(1).PixelList;
        
        tailbase_x        = max(temp(:,1));
        tailbase_y        = tailfits(n,1) * tailbase_x + tailfits(n,2);
        fitset            = [tailbase_x tailbase_y ; headloc];
        intersects(n,:)   = [tailbase_x tailbase_y];
        
        bodyfits(n,:)     = polyfit(fitset(:,1),fitset(:,2),1);
        
        diff_x            = tailbase_x - headloc(1);
        diff_y            = tailbase_y - headloc(2);
        bodyangle(n)      = -atand(diff_y / diff_x);
        
        diff_x            = min(temp(:,1)) - tailbase_x;
        diff_y            = tailfits(n,1) * min(temp(:,1)) + tailfits(n,2);
        tailangle(n)      = -atand(diff_y / diff_x);
    end
end

for n = 1:length(objects)
    
    if ~isempty(objects{n})
        %make rotated objects entry
        rot_mat   = [ cosd(bodyangle(n)) -sind(bodyangle(n)) ; sind(bodyangle(n)) cosd(bodyangle(n)) ];
        
        for q = 1:length(objects{n})
            
            % temporarily store the current pixel list
            temp_pixels = objects{n}(q).PixelList;
            
            % load the original frame
            img         = double(imread(tiffs(n+firstframe).name));
            
            values = [];
            
            % perform within-object-thresholding
            for pixel = 1:length(temp_pixels(:,1))
                values = [values ; img(temp_pixels(pixel,2),temp_pixels(pixel,1))];
            end
            
            %values           = eye(size(values)) .* values * ones(length(values(:,1)),1);
            temp_pixels      = temp_pixels((values > mean(values)),:);
            temp_pixels(:,1) = temp_pixels(:,1) - headloc(1);
            temp_pixels(:,2) = temp_pixels(:,2) - headloc(2);
            
            
            for pixel = 1:length(temp_pixels(:,1))
            
                temp_pixels(pixel,:) = rot_mat * temp_pixels(pixel,:)';
                
            end
            
            rotatedobjects{n}(q).PixelList = temp_pixels;
        end
        
    end
end

cd(oldDir);