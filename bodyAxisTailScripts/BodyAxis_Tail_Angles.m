%%  Code by J.R. De Gruijl (j.de.gruijl@nin.knaw.nl), revisions J.R. De Gruijl and T.M. Hoogland 2014
%  ____            _                      _    _______    _ _                        _           
% |  _ \          | |         /\         (_)  |__   __|  (_) |     /\               | |          
% | |_) | ___   __| |_   _   /  \   __  ___ ___  | | __ _ _| |    /  \   _ __   __ _| | ___  ___ 
% |  _ < / _ \ / _` | | | | / /\ \  \ \/ / / __| | |/ _` | | |   / /\ \ | '_ \ / _` | |/ _ \/ __|
% | |_) | (_) | (_| | |_| |/ ____ \  >  <| \__ \ | | (_| | | |  / ____ \| | | | (_| | |  __/\__ \
% |____/ \___/ \__,_|\__, /_/    \_\/_/\_\_|___/ |_|\__,_|_|_| /_/    \_\_| |_|\__, |_|\___||___/
%                     __/ |                  ______        ______               __/ |            
%                    |___/                  |______|      |______|             |___/             
%
% 
% 
                   
function varargout = BodyAxis_Tail_Angles(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BodyAxis_Tail_Angles_OpeningFcn, ...
                   'gui_OutputFcn',  @BodyAxis_Tail_Angles_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before BodyAxis_Tail_Angles is made visible.
function BodyAxis_Tail_Angles_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

% Check the folder contents
currentFolderState = get_folder_state(cd);
handles.vars.folderState = currentFolderState;
set(handles.directoryDisplay,'String',currentFolderState.name);
set(handles.numberOfImgsDisplay,'String',['Number of TIFF images: ' int2str(currentFolderState.frames)]);
set(handles.motionDetectState,'String',['Motion detection done: ' currentFolderState.motion]);
set(handles.preprocessingDoneDisplay,'String',['Images pre-processed: ' currentFolderState.preprocessed]);
set(handles.framesExcludedDisplay,'String',['Frames excluded from analysis: ' currentFolderState.exclude_frames]);
set(handles.bodyAxisIndication,'String',['Body axis detection done: ' currentFolderState.body_axis]);

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = BodyAxis_Tail_Angles_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% --- Executes on button press in folderSelectButton.
function folderSelectButton_Callback(hObject, eventdata, handles)

folder = uigetdir;
cd(folder);
currentFolderState = get_folder_state(folder);
handles.vars.folderState = currentFolderState;
set(handles.directoryDisplay,'String',currentFolderState.name);
set(handles.numberOfImgsDisplay,'String',['Number of TIFF images: ' int2str(currentFolderState.frames)]);
set(handles.motionDetectState,'String',['Motion detection done: ' currentFolderState.motion]);
set(handles.preprocessingDoneDisplay,'String',['Images pre-processed: ' currentFolderState.preprocessed]);
set(handles.framesExcludedDisplay,'String',['Frames excluded from analysis: ' currentFolderState.exclude_frames]);
set(handles.bodyAxisIndication,'String',['Body axis detection done: ' currentFolderState.body_axis]);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in preprocessTiffs.
function preprocessTiffs_Callback(hObject, eventdata, handles)

image_preprocessing;

% --- Executes on button press in getMotionButton.
function getMotionButton_Callback(hObject, eventdata, handles)

motion_detector;

% --- Executes on button press in gaitTrackingButton.
function gaitTrackingButton_Callback(hObject, eventdata, handles)

clustering_GUI;

% --- Executes on button press in excludeFramesButton.
function excludeFramesButton_Callback(hObject, eventdata, handles)

exclude_frames_GUI;

% --- Executes on button press in bodyAxisButton.
function bodyAxisButton_Callback(hObject, eventdata, handles)

if exist('preprocessed','dir')
    headloc_GUI;
else
    disp('Required data not found. Has data been pre-processed?');
end


% --- Executes on button press in thresholdButton.
function thresholdButton_Callback(hObject, eventdata, handles)

thresholding_GUI;
