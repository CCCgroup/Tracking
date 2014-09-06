function [] = filter_images_scripted(folder)

oldDir = cd;
cd(folder)

files = dir('*.tif');

% start at #2 to exclude the background image backImg.tif
for n = 2:length(files)
    
    % open file
    img = double(imread(files(n).name));
    
    % median filter
    img = medfilt2(img, [5 5]);
    
    % gaussian filter
    img = imgaussian(img,2);
    
    % convert to 8-bit image
    img = uint8(round(img));
    
    % save result
    imwrite(img,files(n).name,'TIFF');
    
end

disp('All images filtered.')
pause(0.001)

cd(oldDir);