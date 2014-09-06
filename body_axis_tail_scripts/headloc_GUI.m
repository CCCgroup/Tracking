function varargout = headloc_GUI(varargin)
% HEADLOC_GUI M-file for headloc_GUI.fig
%      HEADLOC_GUI, by itself, creates a new HEADLOC_GUI or raises the existing
%      singleton*.
%
%      H = HEADLOC_GUI returns the handle to a new HEADLOC_GUI or the handle to
%      the existing singleton*.
%
%      HEADLOC_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HEADLOC_GUI.M with the given input arguments.
%
%      HEADLOC_GUI('Property','Value',...) creates a new HEADLOC_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before headloc_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to headloc_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help headloc_GUI

% Last Modified by GUIDE v2.5 26-Feb-2013 13:01:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @headloc_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @headloc_GUI_OutputFcn, ...
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

% --- Executes just before headloc_GUI is made visible.
function headloc_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to headloc_GUI (see VARARGIN)

% Choose default command line output for headloc_GUI
handles.output = hObject;

% This sets up the initial plot - only do when we are invisible
% so window can get raised using headloc_GUI.
if strcmp(get(hObject,'Visible'),'off')
    try
        axes(handles.axes1);
        cla;
        img = double(imread([cd filesep 'preprocessed' filesep 'backImg.tif']));
        handles.vars.img    = img;
        %img = double(img) ./ double(max(max(img)));
        image(img);
        colormap gray
        axis off
    catch
        handles.vars.img = [];
    end
end

handles.vars.coords = [NaN NaN];


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes headloc_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = headloc_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in redoButton.
function redoButton_Callback(hObject, eventdata, handles)
% hObject    handle to redoButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
handles.vars.coords = ginput(1);
cla
hold on
image(handles.vars.img)
scatter(handles.vars.coords(1),handles.vars.coords(2),'*r');
hold off
set(handles.exitButton,'Enable','on');

guidata(hObject, handles);

% --- Executes on button press in showBackImg.
function showBackImg_Callback(hObject, eventdata, handles)
% hObject    handle to showBackImg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
cla;
try
    handles.vars.img = double(imread([cd filesep 'preprocessed' filesep 'backImg.tif']));
    %img = double(img) ./ double(max(max(img)));
    hold on
    image(handles.vars.img);
    scatter(handles.vars.coords(1),handles.vars.coords(2),'*r');
    colormap gray
    axis off
catch
end
guidata(hObject, handles);

% --- Executes on button press in exitButton.
function exitButton_Callback(hObject, eventdata, handles)
% hObject    handle to exitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
head_coords = handles.vars.coords;
save('headloc.mat','head_coords');
body_axis_GUI;
delete(handles.figure1)


% --- Executes on button press in showRandomImg.
function showRandomImg_Callback(hObject, eventdata, handles)
% hObject    handle to showRandomImg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
cla;
files = dir('*.tif');
index = randi(length(files),1,1);
try
    handles.vars.img = double(imread(files(index).name));
    %img = double(img) ./ double(max(max(img)));
    hold on
    image(handles.vars.img);
    scatter(handles.vars.coords(1),handles.vars.coords(2),'*r');
    colormap gray
    axis off
catch
end
guidata(hObject, handles);
