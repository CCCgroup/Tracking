function [frames,backImg,elements] = backgroundSubtract_currentDir()

folder = cd;

files  = dir('*.tif');
frames = length(files);

diffs = zeros(frames-1,1);

for n = 2:frames
    
    img1 = imread(strcat(folder,filesep,files(n).name));
    img2 = imread(strcat(folder,filesep,files(n-1).name));
    
    img1 = double(img1);
    img2 = double(img2);
    
    theChange = sum(sum(abs(img1 - img2)));
    
    diffs(n-1) = theChange;
    
end

average = mean(diffs);
sigma   =  std(diffs);

imgDims = size(img1);

backImg = zeros(imgDims);

imageCount = 0;
elements   = [];

for n = 2:frames
    
    img1 = imread(strcat(folder,filesep,files(n).name));
    img2 = imread(strcat(folder,filesep,files(n-1).name));
    
    img1 = double(img1);
    img2 = double(img2);
    
    theChange = sum(sum(abs(img1 - img2)));
    
    if theChange > (average + (1.5 * sigma))
        
%             img2_t = reshape(img2(:,385:end),1,[]);
%             
%             [~,ind2] = isMultiMember(255,img2_t);%(q,385:end));
%             
%             img2_t(ind2) = 0;
%             
%             img2_t = reshape(img2_t,256,[]);
%             
%             img2(:,385:end) = img2_t;
        
        imageCount = imageCount + 1;
        backImg    = ((1/imageCount) .* img2) + (((imageCount - 1)/imageCount) .* backImg);
        elements = [elements ; n];
        
    end
    
end

mkdir(folder,'preprocessed');

for n = 1:frames
    
    img = imread(strcat(folder,filesep,files(n).name));
    
%     img_t = reshape(img(:,385:end),1,[]);
%     [~,ind] = isMultiMember(255,img_t);
%     img_t(ind) = 0;
%     img_t = reshape(img_t,256,[]);
%     
%     img(:,385:end) = img_t;
%     
%     for q = 1:length(img(:,1))
%         
%         [~,ind] = isMultiMember(255,img(q,385:end));
%         
%         if ~isempty(ind)
%             for m = 1:length(ind)
%                 img(q,ind(m) + 384) = 0;
%             end
%         end
%         
%     end
    
    img = double(img);
    
    img = img - backImg;
    
    img = round(2 .* img);
    
    for k = 1:imgDims(1)
        for m = 1:imgDims(2)
            if sign(img(k,m)) == -1
                img(k,m) = 0;
            end
        end
    end
    
    img = uint8(img);
    
    %histogram = (((n-1)/n) .* histogram) + ((1 / n) .* hist256(img));
    
    imwrite(img,[folder filesep 'preprocessed' filesep 'processed_' files(n).name],'TIFF');
    
end

% frames
% elements

pause(0.001)

imwrite(uint8(round(backImg)), [folder filesep 'preprocessed' filesep 'backImg.tif'], 'TIFF');
save([folder filesep 'preprocessed' filesep 'backImg.mat'],'backImg');