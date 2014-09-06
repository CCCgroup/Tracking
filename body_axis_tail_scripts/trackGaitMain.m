function varargout = trackGaitMain(varargin)
% TRACKGAITMAIN MATLAB code for trackGaitMain.fig
%      TRACKGAITMAIN, by itself, creates a new TRACKGAITMAIN or raises the existing
%      singleton*.
%
%      H = TRACKGAITMAIN returns the handle to a new TRACKGAITMAIN or the handle to
%      the existing singleton*.
%
%      TRACKGAITMAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRACKGAITMAIN.M with the given input arguments.
%
%      TRACKGAITMAIN('Property','Value',...) creates a new TRACKGAITMAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trackGaitMain_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trackGaitMain_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trackGaitMain

% Last Modified by GUIDE v2.5 26-Nov-2013 10:06:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trackGaitMain_OpeningFcn, ...
                   'gui_OutputFcn',  @trackGaitMain_OutputFcn, ...
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


% --- Executes just before trackGaitMain is made visible.
function trackGaitMain_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trackGaitMain (see VARARGIN)

% Choose default command line output for trackGaitMain
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

% UIWAIT makes trackGaitMain wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = trackGaitMain_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in folderSelectButton.
function folderSelectButton_Callback(hObject, eventdata, handles)
% hObject    handle to folderSelectButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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
% hObject    handle to preprocessTiffs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
image_preprocessing;

% --- Executes on button press in getMotionButton.
function getMotionButton_Callback(hObject, eventdata, handles)
% hObject    handle to getMotionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
motion_detector;

% --- Executes on button press in gaitTrackingButton.
function gaitTrackingButton_Callback(hObject, eventdata, handles)
% hObject    handle to gaitTrackingButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clustering_GUI;

% --- Executes on button press in excludeFramesButton.
function excludeFramesButton_Callback(hObject, eventdata, handles)
% hObject    handle to excludeFramesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
exclude_frames_GUI;

% --- Executes on button press in bodyAxisButton.
function bodyAxisButton_Callback(hObject, eventdata, handles)
% hObject    handle to bodyAxisButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if exist('preprocessed','dir')
    headloc_GUI;
else
    disp('Required data not found. Has data been pre-processed?');
end


% --- Executes on button press in thresholdButton.
function thresholdButton_Callback(hObject, eventdata, handles)
% hObject    handle to thresholdButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
thresholding_GUI;
