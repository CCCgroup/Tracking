function [minVal,maxVal,hist] = get_img_val_range(img)

dims     = size(img);

%disp('Reshaping image...')
img      = reshape(img,dims(1)*dims(2),1);

img      = double(img);
img      = img ./ max(img);

pixvals  = unique(img);

minVal   = pixvals(  1);
maxVal   = pixvals(end);

pixnums  = zeros(size(pixvals));

%disp('Performing pixel counts...')
for n = 1:length(pixvals)
    pixnums(n) = sum(ismember(img,pixvals(n)));
end

hist = [pixvals pixnums];