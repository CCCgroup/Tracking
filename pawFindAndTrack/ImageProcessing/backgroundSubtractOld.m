function [frames,backImg,elements] = backgroundSubtract(folder)

tic

disp('Performing background subtraction on images in folder: ')
disp(['     ' folder])


try
    load(strcat(folder,filesep, 'bufferReady.mat'))
catch
    strip_buffer_times(); % this function call will create bufferready.mat if timestamps are present in tif files
end

frames = length(bufferReady);

disp(['Total number of image files according to "bufferReady.mat": ' int2str(frames)])

clear bufferReady

diffs = zeros(frames-1,1);


% sort filenames in current directory

dirstruct = dir(folder);

[sorted_names,sorted_index] = sortrows({dirstruct.name}');

%Then eliminate all but the .tif files
filecount = 0;
fileindices = [];
for i=1:length(sorted_names)
    if ~isdir(sorted_names{i})
        [path name ext] = fileparts(sorted_names{i});
        
        if (strcmp(ext,'.tif') || strcmp(ext,'.Tiff'))
            filecount = filecount+1;
            fileindices = [fileindices i];
        end
    end
end

if filecount > 0
    files = cell(filecount,1);
    for i=1:filecount
        files{i} = sorted_names{fileindices(i)};
    end
else
    files = {};
end

nums_after_img=zeros(1,length(files));

for i=1:length(files)
    
    %find img and .tif end and start
    loc1=findstr(files{i},'g');
    loc2=findstr(files{i},'.');
    
    %store filestring in tmp variable and convert to double
    tmp=files{i};
    nums_after_img(1,i)=str2double(tmp(loc1+1:loc2-1));
   
end
    

filesnew=[char(files) nums_after_img'];

char_size=size(filesnew,2);  

filesnew=sortrows(filesnew,char_size);

filesnew=cellstr(filesnew(:,1:char_size-1))  
% files
    



disp('Establishing inter-image change threshold...')



for n = 2:frames
    
    if mod(n,100) == 0
        disp(['Working on frames ' int2str(n-1) ' and ' int2str(n) '.'])
    end
    
     try
    img1 = imread(files{n});
    img2 = imread(files{n-1});
    
    img1 = double(img1);
    img2 = double(img2);
    
    theChange = sum(sum(abs(img1 - img2)));
    
    diffs(n-1) = theChange;
     catch
% 
%             disp(['     ERROR: ' files{n-1} ' does not exist!'])
%             frames = n-1;
%     
%         break
     end
    
end

average = mean(diffs);
sigma   =  std(diffs);

disp('Rendering background image...')

imgDims = size(img1);

backImg = zeros(imgDims);

imageCount = 0;
elements   = [];

for n = 2:frames

    try
    img1 = imread(files{n});
    img2 = imread(files{n-1});
  
    img1 = double(img1);
    img2 = double(img2);
    
    theChange = sum(sum(abs(img1 - img2)));
    
    if theChange > (average + (1 * sigma))
        
        disp(['Including frame #' int2str(n)]);
        
      tic
            img2_t = reshape(img2(:,400:end),1,[]); %400 coordinate in image defining half image to use
      toc      
      disp('time taken to complete reshape');
      
      tic
            [~,ind2] = isMultiMember(255,img2_t); 
      toc
      disp('time taken to complete isMultiMember');
           
            img2_t(ind2) = 0;

            clear ind2;
       tic   
            img2_t = reshape(img2_t,256,[]);
            
       toc
       disp('time taken to complete reshape');
       
            img2(:,400:end) = img2_t;
            
            clear img2_t;
        
        imageCount = imageCount + 1;
        backImg    = ((1/imageCount) .* img2) + (((imageCount - 1)/imageCount) .* backImg);
        elements = [elements ; n];
       
    end
    catch
    end
end

disp(['Images used for background image: ' int2str(imageCount) ' out of ' int2str(frames)])

disp('Saving new images in: ')
disp(['     ' folder filesep 'Paws']);

mkdir(folder, 'Paws');
disp('made folder Paws');

for n = 1:frames
  n   
    if mod(n,100) == 0
        disp(['Number of frames processed: ' int2str(n) ' out of ' int2str(frames)])
    end
    
    img = imread(files{n});
    
%     img_t = reshape(img(:,385:end),1,[]);
%     [~,ind] = isMultiMember(255,img_t); % was isMultiMember(255:, img_t);
%     img_t(ind) = 0;
%     img_t = reshape(img_t,256,[]);
%     
%     img(:,385:end) = img_t;
    

    
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
        
    imwrite(img,[folder filesep 'Paws' filesep 'paws' int2str(n-1) '.tif'],'TIFF');
    
end

disp(['All ' int2str(frames) ' images saved.'])
disp('Saving background image as:')
disp(['     ' folder filesep 'Paws' filesep 'backImg.tif'])
disp(['     ' folder filesep 'Paws' filesep 'backImg.mat'])

imwrite(uint8(round(backImg)), [folder filesep 'Paws' filesep 'backImg.tif'], 'TIFF');
save([folder filesep 'Paws' filesep 'backImg.mat'],'backImg');

disp('Background subtraction done.')

toc
