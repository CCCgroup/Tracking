% paw tracking object detection
function [theList] = objectDetection(img,theta,criterion)

%% Preprocessing and determining threshold
imgBW = double(img);
% if max(size(imgBW)) > 256
%     imgBW = imgBW(:,1:350);             % crop image
% end
imgBW = imgBW ./ max(max(imgBW));
%theta = 2 * mean(std(img));

%% Tresholding of the image
imgBW = im2bw(imgBW,theta);

%% Extract all the objects from the thresholded image
overview = bwconncomp(imgBW, 4);

objectArea        = regionprops(overview,'Area');
objectOrientation = regionprops(overview,'Orientation');
objectCentroid    = regionprops(overview,'Centroid');
objectPixelList   = regionprops(overview,'PixelList');

%objectData        = [objectArea ; objectOrientation ; objectCentroid];

%% Filter out objects that do not meet the size criterion

count = 1;
finalData = {};

for n = 1:length(objectArea)
    
    if objectArea(n).Area < criterion
        
        % remove this object from the list
        
    else
        
        % add it to final list
        finalData{count}.Area        = objectArea(n).Area;
        finalData{count}.Centroid    = objectCentroid(n).Centroid;
        finalData{count}.Orientation = objectOrientation(n).Orientation;
        finalData{count}.PixelList   = objectPixelList(n).PixelList;
        count = count + 1;
        
    end
    
end


%% Return end result
theList = finalData;