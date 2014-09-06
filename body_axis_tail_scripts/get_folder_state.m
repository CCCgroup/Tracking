function folderState = get_folder_state(folder)

oldDir = cd;
cd(folder);

folderState.name   = folder;
folderState.frames = length(dir('*.tif'));

motion = dir('motion*.mat');
if ~isempty(motion)
    folderState.motion = 'yes';
else
    folderState.motion = 'no';
end

if exist('preprocessed','dir')
    folderState.preprocessed = 'yes';
else
    folderState.preprocessed = 'no';
end

if exist('exclude_frames.mat','file')
    folderState.exclude_frames = 'yes';
else
    folderState.exclude_frames = 'no';
end

if exist('body_axis.mat','file')
    folderState.body_axis = 'yes';
else
    folderState.body_axis = 'no';
end

cd(oldDir);