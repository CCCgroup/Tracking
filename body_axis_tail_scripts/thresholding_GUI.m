function varargout = thresholding_GUI(varargin)
% THRESHOLDING_GUI M-file for thresholding_GUI.fig
%      THRESHOLDING_GUI, by itself, creates a new THRESHOLDING_GUI or raises the existing
%      singleton*.
%
%      H = THRESHOLDING_GUI returns the handle to a new THRESHOLDING_GUI or the handle to
%      the existing singleton*.
%
%      THRESHOLDING_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in THRESHOLDING_GUI.M with the given input arguments.
%
%      THRESHOLDING_GUI('Property','Value',...) creates a new THRESHOLDING_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before thresholding_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to thresholding_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help thresholding_GUI

% Last Modified by GUIDE v2.5 22-Apr-2013 15:29:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @thresholding_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @thresholding_GUI_OutputFcn, ...
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


% --- Executes just before thresholding_GUI is made visible.
function thresholding_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to thresholding_GUI (see VARARGIN)

% Choose default command line output for thresholding_GUI
handles.output = hObject;

% Get list of preprocessed tiffs
cd('preprocessed')
theDir  = cd;
imgList = dir('*.tif');
cd ..

% Select a preprocessed tiff image at random to display
ind = randi(length(imgList),1);
img = imread([theDir filesep imgList(ind).name]);

img = double(img);
img = img ./ max(max(img));

[themin,themax,hst] = get_img_val_range(img);

axes(handles.imgAxes)
image(round(255.*img))
colormap(gray(255))
axis off

axes(handles.histAxes)
plot(hst(:,1),hst(:,2),'k','LineWidth',2)
title('Histogram')

handles.vars.img  = img;
handles.vars.min  = themin;
handles.vars.max  = themax;
handles.vars.hist = hst;
handles.vars.dir  = theDir;
handles.vars.tiff = imgList;
handles.vars.theta= 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes thresholding_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = thresholding_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in randomImg.
function randomImg_Callback(hObject, eventdata, handles)
% hObject    handle to randomImg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ind = randi(length(handles.vars.tiff),1);
img = imread([handles.vars.dir filesep handles.vars.tiff(ind).name]);

img = double(img);
img = img ./ max(max(img));

[~,~,hst] = get_img_val_range(img);

handles.vars.hist = hst;
handles.vars.img  = img;

guidata(hObject, handles);

% rescale image pixel values according to settings
img(img < handles.vars.min) = 0;
img(img > handles.vars.max) = 0;

hst = handles.vars.hist;

ind = (hst(:,1) >= handles.vars.min);
hst = hst(ind,:);

ind = (hst(:,1) <= handles.vars.max);
hst = hst(ind,:);

if handles.vars.theta
axes(handles.imgAxes)
cla
image(255*sign(img))
colormap(gray(255))
axis off    
else
axes(handles.imgAxes)
cla
image(round(255.*img))
colormap(gray(255))
axis off
end

axes(handles.histAxes)
cla
plot(hst(:,1),hst(:,2),'k','LineWidth',2)
title('Histogram')

function minVal_Callback(hObject, eventdata, handles)
% hObject    handle to minVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minVal as text
%        str2double(get(hObject,'String')) returns contents of minVal as a double
try
    minval = str2double(get(hObject,'String'));
catch
    minval = 0;
end


handles.vars.min = minval;

hst = handles.vars.hist;

ind = (hst(:,1) >= minval);
hst = hst(ind,:);

ind = (hst(:,1) <= handles.vars.max);
hst = hst(ind,:);

img = handles.vars.img;
img(img < minval) = 0;
img(img > handles.vars.max) = 0;

if handles.vars.theta
axes(handles.imgAxes)
cla
image(255*sign(img))
colormap(gray(255))
axis off    
else
axes(handles.imgAxes)
cla
image(round(255.*img))
colormap(gray(255))
axis off
end

axes(handles.histAxes)
cla
plot(hst(:,1),hst(:,2),'k','LineWidth',2)
title('Histogram')

guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function minVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxVal_Callback(hObject, eventdata, handles)
% hObject    handle to maxVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxVal as text
%        str2double(get(hObject,'String')) returns contents of maxVal as a double
try
    maxval = str2double(get(hObject,'String'));
catch
    maxval = 1;
end


handles.vars.max = maxval;

hst = handles.vars.hist;

ind = (hst(:,1) >= handles.vars.min);
hst = hst(ind,:);

ind = (hst(:,1) <= maxval);
hst = hst(ind,:);

img = handles.vars.img;
img(img < handles.vars.min) = 0;
img(img > maxval) = 0;

if handles.vars.theta
axes(handles.imgAxes)
cla
image(255*sign(img))
colormap(gray(255))
axis off    
else
axes(handles.imgAxes)
cla
image(round(255.*img))
colormap(gray(255))
axis off
end

axes(handles.histAxes)
cla
plot(hst(:,1),hst(:,2),'k','LineWidth',2)
title('Histogram')

guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function maxVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in threshBool.
function threshBool_Callback(hObject, eventdata, handles)
% hObject    handle to threshBool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of threshBool
handles.vars.theta = get(hObject,'Value');

img = handles.vars.img;
img(img < handles.vars.min) = 0;
img(img > handles.vars.max) = 0;

if handles.vars.theta
axes(handles.imgAxes)
cla
image(255*sign(img))
colormap(gray(255))
axis off    
else
axes(handles.imgAxes)
cla
image(round(255.*img))
colormap(gray(255))
axis off
end

guidata(hObject,handles);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

minval = handles.vars.min;
maxval = handles.vars.max;
%cd ..
save('pixelrange.mat','minval','maxval');
% update values in trackGaitMain!!!
delete(handles.figure1)
