function varargout = image_preprocessing(varargin)
% IMAGE_PREPROCESSING MATLAB code for image_preprocessing.fig
%      IMAGE_PREPROCESSING, by itself, creates a new IMAGE_PREPROCESSING or raises the existing
%      singleton*.
%
%      H = IMAGE_PREPROCESSING returns the handle to a new IMAGE_PREPROCESSING or the handle to
%      the existing singleton*.
%
%      IMAGE_PREPROCESSING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGE_PREPROCESSING.M with the given input arguments.
%
%      IMAGE_PREPROCESSING('Property','Value',...) creates a new IMAGE_PREPROCESSING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before image_preprocessing_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to image_preprocessing_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help image_preprocessing

% Last Modified by GUIDE v2.5 22-Feb-2013 14:28:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @image_preprocessing_OpeningFcn, ...
                   'gui_OutputFcn',  @image_preprocessing_OutputFcn, ...
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


% --- Executes just before image_preprocessing is made visible.
function image_preprocessing_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to image_preprocessing (see VARARGIN)

% Choose default command line output for image_preprocessing
handles.output = hObject;

currentFolder = cd;
set(handles.folderIndicatorText,'String',['Folder: ' currentFolder]);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes image_preprocessing wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = image_preprocessing_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in viewResult.
function viewResult_Callback(hObject, eventdata, handles)
% hObject    handle to viewResult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Play the body axis extraction results over auto-thresholded images


% --- Executes on button press in exitButton.
function exitButton_Callback(hObject, eventdata, handles)
% hObject    handle to exitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = image_preprocessing;
figure1_CloseRequestFcn(h, eventdata, handles);


% --- Executes on button press in processButton.
function processButton_Callback(hObject, eventdata, handles)
% hObject    handle to processButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% PROCESS THE DATA
% 0. If needed, generate bufferReady...
if ~exist('bufferReady.mat','file')
    set(handles.messagesString,'String','Generating image time stamp file...');
    drawnow();
    pause(0.001);
    bufferReady = get_bufferReady;
end

% 1. Background subtraction
disp('Performing background subtraction. This may take a while...');
set(handles.messagesString,'String','Performing background subtraction. This may take a while...');
drawnow();
pause(0.001);
[~,backImg] = backgroundSubtract_currentDir;

% 2. Filter images
disp('Filtering background-subtracted images. This may take a while...');
set(handles.messagesString,'String','Filtering background-subtracted images. This may take a while...');
drawnow();
pause(0.001);
filter_images_scripted([cd filesep 'preprocessed']);

% 3. Stretch the contrast of the TIFFs
disp('Stretching contrast of filtered images. This may take a while...');
set(handles.messagesString,'String','Stretching contrast of filtered images. This may take a while...');
drawnow();
pause(0.001);
stretch_contrast_GUI([cd filesep 'preprocessed']);

% 4. Perform auto-thresholding
set(handles.messagesString,'String','Determining threshold for object extraction...');
drawnow();
pause(0.001);


% 5. Get head location
% set(handles.messagesString,'String','Please indicate head location...');
% headloc_GUI;

% ADD CODE THAT WAITS FOR HEADLOC_GUI TO FINISH???

% % 6. Perform body axis extraction (if head location is known)
% set(handles.messagesString,'String','Determining body axis in all images. This may take a while...');
% drawnow();
% pause(0.001);

% ENABLE THE "VIEW RESULT" AND "EXIT" BUTTONS
set(handles.messagesString,'String','Pre-processing done!');
drawnow();
%h = handles.viewResult;
set(handles.viewResult,'Enable', 'on');
%h = handles.exitButton;
set(handles.exitButton,'Enable', 'on');


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

folderState                = get_folder_state(cd);
h                          = trackGaitMain;
the_data                   = guidata(h);
the_data.vars.folderState  = folderState;
set(the_data.preprocessingDoneDisplay,'String',['Images pre-processed: ' folderState.preprocessed]);
guidata(h,the_data)
drawnow();
delete(hObject);