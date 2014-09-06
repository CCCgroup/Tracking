function varargout = frameSelector(varargin)
% FRAMESELECTOR M-file for frameSelector.fig
%      FRAMESELECTOR, by itself, creates a new FRAMESELECTOR or raises the existing
%      singleton*.
%
%      H = FRAMESELECTOR returns the handle to a new FRAMESELECTOR or the handle to
%      the existing singleton*.
%
%      FRAMESELECTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FRAMESELECTOR.M with the given input arguments.
%
%      FRAMESELECTOR('Property','Value',...) creates a new FRAMESELECTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before frameSelector_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to frameSelector_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help frameSelector

% Last Modified by GUIDE v2.5 21-Sep-2011 17:14:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @frameSelector_OpeningFcn, ...
                   'gui_OutputFcn',  @frameSelector_OutputFcn, ...
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


% --- Executes just before frameSelector is made visible.
function frameSelector_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to frameSelector (see VARARGIN)

% Choose default command line output for frameSelector
handles.output = hObject;

% Get/generate some valuable context

tempFolder = cd;

handles.variables.theFolder  = [tempFolder filesep 'Paws'];

handles.variables.theImg     = imread([handles.variables.theFolder filesep 'paws0.tif']);

image(handles.variables.theImg);
colormap(gray(256));
axis([1 512 1 256]);
axis ij
axis off

temp = dir('*.tif');
handles.variables.nrOfFrames   = length(temp);    % get number of image files

handles.variables.currentFrame = 1;
handles.variables.firstFrame   = 1;
handles.variables.lastFrame    = 100;

set(handles.frameTotal, 'String', ['Select frames to analyze. Total number of frames in this sequence: ' int2str(handles.variables.nrOfFrames)]);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes frameSelector wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = frameSelector_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in doneButton.
function doneButton_Callback(hObject, eventdata, handles)
% hObject    handle to doneButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% save the settings

assignin('base','firstFrame',handles.variables.firstFrame);
assignin('base','lastFrame',handles.variables.lastFrame);

%save([handle.variables.folder filesep 'criteria.mat'], 'theta', 'criterion');

delete(handles.figure1)


function firstFrame_Callback(hObject, eventdata, handles)
% hObject    handle to firstFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of firstFrame as text
%        str2double(get(hObject,'String')) returns contents of firstFrame as a double


setappdata(gcbf,'running',false);

targetFrame = str2double(get(hObject, 'String'));
if isnan(targetFrame)
    set(hObject, 'String', 0);
    errordlg('Input must be an integer','Error');
end

if targetFrame > 0
    handles.variables.firstFrame = targetFrame;
else
    set(hObject, 'String', 1);
    handles.variables.firstFrame = 1;
end
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function firstFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to firstFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lastFrame_Callback(hObject, eventdata, handles)
% hObject    handle to lastFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


setappdata(gcbf,'running',false);

% Hints: get(hObject,'String') returns contents of lastFrame as text
%        str2double(get(hObject,'String')) returns contents of lastFrame as a double
targetFrame = str2double(get(hObject, 'String'));
if isnan(targetFrame)
    set(hObject, 'String', 0);
    errordlg('Input must be an integer','Error');
end

if targetFrame > 0
    handles.variables.lastFrame = targetFrame;
else
    set(hObject, 'String', 1);
    handles.variables.lastFrame = 1;
end
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function lastFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lastFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in showButton.
function showButton_Callback(hObject, eventdata, handles)
% hObject    handle to showButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



setappdata(gcbf, 'running', true); %code for interrupting movie control
axis off;    

%   hp= impixelinfo;
%      set(hp,'Position',[1 1 1 1]);

n= handles.variables.firstFrame;

while(getappdata(gcbf,'running') && n<handles.variables.lastFrame)
    
 
    % do the whole update variables...
    handles.variables.currentFrame = n;
       
    % ...load image...
    handles.variables.theImg     = imread([handles.variables.theFolder filesep 'paws' int2str(n-1) '.tif']);
   n=n+1;
    % ... and draw stuff thang.
    cla
    
    hold on
    image(handles.variables.theImg)
    text(20,20,strcat('Frame #',int2str(n)),'Color', 'r')
    hold off
    
        
    axis([1 512 1 256])
    axis ij
    axis off
        
    drawnow();
        
    % and update the objects
    guidata(handles.output,handles);
    
end




