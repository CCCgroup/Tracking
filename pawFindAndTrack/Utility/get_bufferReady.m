function bufferReady = get_bufferReady()

%folder = uigetdir();
%cd(folder);

files = dir('*.tif');

bufferReady = zeros(length(files),1);

for n = 1:length(files)
    
    filename = files(n).name;
    
    loc1 = findstr(filename,'g') + 1;
    loc2 = findstr(filename,'.') - 1;
    
    bufferReady(n) = str2double(filename(loc1:loc2));
   
end

% Sort the result, just in case.
bufferReady = sort(bufferReady);

save('bufferReady.mat', 'bufferReady');