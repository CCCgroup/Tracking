function [] = stretch_contrast_GUI(folder)

oldDir = cd;
cd(folder);

  tiffs = dir('*.tif');
n_tiffs = length(tiffs);

minval  = 1000;
maxval  = 0;

dims   = size(imread(tiffs(1).name));
pixels = dims(1) * dims(2);

normhist = zeros(255,1);

%disp('Getting max and min values...')

for n = 2:n_tiffs
    
    img = imread(tiffs(n).name);
    
    the_min = min(min(img));
    the_max = max(max(img));
    
    if (the_min < minval)
        minval = double(the_min);
    end
    
    if (the_max > maxval)
        maxval = double(the_max);
    end
    
    for q = 1:256
        
        img = reshape(img,pixels,1);
        normhist(q) = sum(ismember(img, (q-1)));
        
    end
    
end

normhist = normhist / n_tiffs;

cut_off = 255 - sum(ismember(normhist,0));

%disp(['Minimum found: ' int2str(minval)])
%disp(['Maximum found: ' int2str(maxval)])

maxval = maxval - minval;

%if ~((minval == 0) && (maxval == 255))

    %mkdir(folder, 'polished');

    %disp(['Polishing ' int2str(n_tiffs) ' files...'])

    for n = 2:n_tiffs
    
        img = double(imread(tiffs(n).name));
        
        img = img - minval;                 % set the lowest value to zero (remove offset)
        
        img = img ./ maxval;                % normalize the image
        
        img = img .* (255 + cut_off);       % increase the contrast in the non-zero range of pixel values linearly
        
        img(img > 255) = 255;
    
        imwrite(uint8(round(img)),tiffs(n).name,'TIFF');
    end

%end

cd(oldDir);