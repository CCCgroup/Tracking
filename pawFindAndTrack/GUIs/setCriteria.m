function varargout = setCriteria(varargin)
% SETCRITERIA M-file for setCriteria.fig
%      SETCRITERIA, by itself, creates a new SETCRITERIA or raises the existing
%      singleton*.
%
%      H = SETCRITERIA returns the handle to a new SETCRITERIA or the handle to
%      the existing singleton*.
%
%      SETCRITERIA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SETCRITERIA.M with the given input arguments.
%
%      SETCRITERIA('Property','Value',...) creates a new SETCRITERIA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before setCriteria_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to setCriteria_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help setCriteria

% Last Modified by GUIDE v2.5 11-May-2011 11:39:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @setCriteria_OpeningFcn, ...
                   'gui_OutputFcn',  @setCriteria_OutputFcn, ...
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


% --- Executes just before setCriteria is made visible.
function setCriteria_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to setCriteria (see VARARGIN)

% Choose default command line output for setCriteria
handles.output = hObject;

% Get/generate some valuable context

tempFolder = cd;

handles.variables.theFolder  = [tempFolder filesep 'Paws'];

temp = dir('*.tif');

handles.variables.nrOfFrames = length(temp);
%handles.variables.randNr     = randi(handles.variables.nrOfFrames,1);

handles.variables.theImg     = imread([handles.variables.theFolder filesep 'paws0.tif']);

image(handles.variables.theImg);
colormap(gray(256));
axis([1 512 1 256]);
axis ij
axis off

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes setCriteria wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = setCriteria_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% save the settings
theta     = get(handles.slider1,'Value');
criterion = round(200 * get(handles.slider3,'Value'));

assignin('base','threshold',theta);
assignin('base','criterion',criterion);

%save([handle.variables.folder filesep 'criteria.mat'], 'theta', 'criterion');

delete(handles.figure1)

% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in pushbutton3. (= draw result)
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.variables.criterion  = round(200 * get(handles.slider3,'Value'));
handles.variables.threshold  = get(handles.slider1,'Value');

imgNr                        = handles.variables.nrOfFrames * get(handles.slider4,'Value');
if imgNr == handles.variables.nrOfFrames
    imgNr = imgNr - 1;
end
handles.variables.theImg     = imread([handles.variables.theFolder filesep 'paws' int2str(imgNr) '.tif']);

handles.variables.theObjects = objectDetection(handles.variables.theImg,handles.variables.threshold,handles.variables.criterion);

hold on

image(handles.variables.theImg)
colormap(gray(256))

for n = 1:length(handles.variables.theObjects)
    
    scatter(handles.variables.theObjects{n}.PixelList(:,1),handles.variables.theObjects{n}.PixelList(:,2), '.r');
    
end

hold off

axis([1 512 1 256])
axis ij
axis off

% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

imgNr                        = handles.variables.nrOfFrames * get(hObject,'Value');
if imgNr == handles.variables.nrOfFrames
    imgNr = imgNr - 1;
end
handles.variables.theImg     = imread([handles.variables.theFolder filesep 'paws' int2str(imgNr) '.tif']);

image(handles.variables.theImg)
colormap(gray(256))
axis([1 512 1 256])
axis ij
axis off

% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
