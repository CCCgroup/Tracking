function objects = detectAllObjects(imgFolder,criterion,threshold,firstFrame,lastFrame)

tic

disp('Running object detection...');
pause(0.001);

objects = {};

count = 0;

for n = firstFrame:lastFrame
    
    img = imread(strcat(imgFolder,filesep, 'Paws', filesep, 'paws',int2str(n-1),'.tif'));
    img = double(img);
    img = medfilt2(img);
    tempObjects = objectDetectionRefined(img,threshold,criterion);
    
    % Filter out artifacts (e.g. lights)
    
    count          = count + 1;
    objects{count} = tempObjects;
    
    if mod(count,100) == 0
        disp(['     ' int2str(count) ' out of ' int2str(lastFrame - firstFrame + 1) ' frames processed so far...']);
    end
    
end

disp(['     All ' int2str(lastFrame - firstFrame + 1) ' frames processed.']);

disp(['Saving result as: ' strcat(imgFolder,filesep, 'Paws', filesep, 'objects.mat')])
pause(0.001);

save(strcat(imgFolder,filesep, 'Paws', filesep, 'objects.mat'),'objects', 'criterion', 'threshold','firstFrame','lastFrame')

disp('Object detection completed.')

toc
