% paw tracking object detection
function [theList] = objectDetectionRefined(img,theta,criterion1)

criterion2 = 4 * criterion1;

%% Preprocessing and determining threshold
imgBW = double(img);
% if max(size(img)) > 256
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
    
    if objectArea(n).Area < criterion1
        
        % remove this object from the list
        
    else
        
        % add it to final list
        finalData{count}.Area        = objectArea(n).Area;
        finalData{count}.Centroid    = objectCentroid(n).Centroid;
        finalData{count}.Orientation = objectOrientation(n).Orientation;
        finalData{count}.PixelList   = objectPixelList(n).PixelList;
        count = count + 1;
        
    end
    
    % if the object is bigger than criterion2 allows, only use the
    % brightest pixels for the object
    if objectArea(n).Area > criterion2
        
        pixelValues = zeros(length(objectPixelList(n).PixelList(:,1)),1);
        
        for m = 1:length(pixelValues)
            
            % find the value
            pixelValues(m) = img(objectPixelList(n).PixelList(m,2),objectPixelList(n).PixelList(m,1));
            
        end
        
        meanValue   = mean(pixelValues);
        
        finalPixelList = [];
        
        for m = 1:length(pixelValues)
            
            % use the mean value to spread the population in two
            if pixelValues(m) > meanValue
                
                finalPixelList = [finalPixelList ; objectPixelList(n).PixelList(m,:)];
                
            end
            
        end
        
        finalCentroid = mean(finalPixelList);
        
        finalData{count - 1}.Centroid  = finalCentroid;
        finalData{count - 1}.PixelList = finalPixelList;
        
    end
    
end


%% Return end result
theList = finalData;