function varargout = motion_detector_trackGait(varargin)
% MOTION_DETECTOR M-file for motion_detector.fig
%      MOTION_DETECTOR, by itself, creates a new MOTION_DETECTOR or raises the existing
%      singleton*.
%
%      H = MOTION_DETECTOR returns the handle to a new MOTION_DETECTOR or the handle to
%      the existing singleton*.
%
%      MOTION_DETECTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOTION_DETECTOR.M with the given input arguments.
%
%      MOTION_DETECTOR('Property','Value',...) creates a new MOTION_DETECTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before motion_detector_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to motion_detector_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help motion_detector

% Last Modified by GUIDE v2.5 22-Mar-2013 12:10:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @motion_detector_trackGait_OpeningFcn, ...
                   'gui_OutputFcn',  @motion_detector_trackGait_OutputFcn, ...
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


% --- Executes just before motion_detector is made visible.
function motion_detector_trackGait_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to motion_detector (see VARARGIN)

% Choose default command line output for motion_detector
handles.output = hObject;

% Initialize some values
handles.variables.filterwidth   = str2double(get(handles.filterWidthField, 'String'));
handles.variables.threshold     = str2double(get(handles.thresholdField, 'String'));
handles.variables.hiatus        = str2double(get(handles.hiatusField, 'String'));

handles.variables.originalData  = rand(2000,1);

handles.variables.motion        = get_movement_vector(handles.variables.originalData, ...
                                                      handles.variables.threshold,    ...
                                                      handles.variables.hiatus,       ...
                                                      handles.variables.filterwidth);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes motion_detector wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = motion_detector_trackGait_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in updateButton.
function updateButton_Callback(hObject, eventdata, handles)
% hObject    handle to updateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get the values for data processing...
handles.variables.filterwidth = str2double(get(handles.filterWidthField, 'String'));
handles.variables.threshold   = str2double(get(handles.thresholdField, 'String'));
handles.variables.hiatus      = str2double(get(handles.hiatusField, 'String'));

% check if data is available?


% process data
if handles.variables.opticalMouse
    [handles.variables.procData,~] = elimWraps_v2([handles.variables.time handles.variables.originalData],10);
else
    [handles.variables.procData,~] = elimWraps_v2([handles.variables.time handles.variables.originalData],0.05);
end

temp = qnd_filter_trace(handles.variables.procData(:,2),round((handles.variables.filterwidth - 1) / 2));

handles.variables.motion        = get_movement_vector(temp,        ...
                                      handles.variables.threshold, ...
                                      handles.variables.hiatus,    ...
                                      handles.variables.filterwidth);
                                                  

                                                  
% clean up the figure
axes(handles.axes1);
cla;
hold on

plot(handles.variables.procData(:,1),handles.variables.procData(:,2),'k');
plot(handles.variables.procData(:,1),handles.variables.procData(:,2) .* handles.variables.motion,'r','LineWidth',2);

hold off

if handles.variables.opticalMouse
    axis([handles.variables.procData(1,1) handles.variables.procData(end,1) 0 max(handles.variables.procData(:,2))]);
    ylabel('Disc position (pixel)')
    xlabel('CPU time stamp (ms)')
else
    axis([handles.variables.procData(1,1) handles.variables.procData(end,1) 0 max(handles.variables.procData(:,2))]);
    ylabel('Disc position (V)')
    xlabel('CPU time stamp (ms)')
end

% Update handles structure
guidata(hObject, handles);


function thresholdField_Callback(hObject, eventdata, handles)
% hObject    handle to thresholdField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thresholdField as text
%        str2double(get(hObject,'String')) returns contents of thresholdField as a double


% --- Executes during object creation, after setting all properties.
function thresholdField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thresholdField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hiatusField_Callback(hObject, eventdata, handles)
% hObject    handle to hiatusField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hiatusField as text
%        str2double(get(hObject,'String')) returns contents of hiatusField as a double


% --- Executes during object creation, after setting all properties.
function hiatusField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hiatusField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in getTraceFile.
function getTraceFile_Callback(hObject, eventdata, handles)
% hObject    handle to getTraceFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.variables.oldDir = cd;
handles.variables.folder = uigetdir(cd,'Select folder to work on...');
cd(handles.variables.folder);
if exist('mousePath.mat','file')
    load mousePath.mat
    handles.variables.originalData = mousePath(:,1); % take X coordinates as motion indicator
    handles.variables.time         = mousePath(:,3);
    handles.variables.opticalMouse = 1;
    cla;
    plot(handles.variables.time,handles.variables.originalData,'k');
    axis([handles.variables.time(1) handles.variables.time(end) 0 1280]);
    ylabel('Relative disc position (pixel)')
elseif exist('analogChannels.mat','file')
    load analogChannels.mat
    [~,handles.variables.originalData,~] = processAnalogSignals(analogChannels);
    handles.variables.time         = handles.variables.originalData(:,1);
    handles.variables.originalData = handles.variables.originalData(:,2);
    handles.variables.opticalMouse = 0;
    % plot the new data
    cla;
    plot(handles.variables.time,handles.variables.originalData,'k');
    axis([handles.variables.time(1) handles.variables.time(end) 0 10]);
    ylabel('Absolute disc position (V)')
end

cd(handles.variables.oldDir);

% update handles
guidata(handles.output,handles);


% --- Executes on button press in saveFileButton.
function saveFileButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveFileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cd(handles.variables.folder);
motion   = handles.variables.motion;
procdata = handles.variables.procData;

save('motion_vector.mat','motion','procdata');

cd(handles.variables.oldDir);

%h = findobj(trackGaitMain, 'flat');



function filterWidthField_Callback(hObject, eventdata, handles)
% hObject    handle to filterWidthField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filterWidthField as text
%        str2double(get(hObject,'String')) returns contents of filterWidthField as a double


% --- Executes during object creation, after setting all properties.
function filterWidthField_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filterWidthField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes when user attempts to close figure1.
function GUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
folderState                = get_folder_state(handles.variables.folder);
h                          = trackGaitMain;
the_data                   = guidata(h);
the_data.vars.folderState  = folderState;
set(the_data.motionDetectState,'String',['Motion detection done: ' folderState.motion]);
guidata(h,the_data);
drawnow();
delete(hObject);


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
