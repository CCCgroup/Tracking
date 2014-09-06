function varargout = checkClassification(varargin)
% CHECKCLASSIFICATION M-file for checkClassification.fig
%      CHECKCLASSIFICATION, by itself, creates a new CHECKCLASSIFICATION or raises the existing
%      singleton*.
%
%      H = CHECKCLASSIFICATION returns the handle to a new CHECKCLASSIFICATION or the handle to
%      the existing singleton*.
%
%      CHECKCLASSIFICATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHECKCLASSIFICATION.M with the given input arguments.
%
%      CHECKCLASSIFICATION('Property','Value',...) creates a new CHECKCLASSIFICATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before checkClassification_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to checkClassification_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help checkClassification

% Last Modified by GUIDE v2.5 15-May-2012 16:14:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @checkClassification_OpeningFcn, ...
                   'gui_OutputFcn',  @checkClassification_OutputFcn, ...
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


% --- Executes just before checkClassification is made visible.
function checkClassification_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to checkClassification (see VARARGIN)

% Choose default command line output for checkClassification
handles.output = hObject;


% sort filenames in current directory

dirstruct = dir(pwd);
    
[sorted_names,sorted_index] = sortrows({dirstruct.name}');

sorted_names

%Then eliminate all but the .tif files
filecount = 0;
fileindices = [];

for i=1:length(sorted_names)
    if ~isdir(sorted_names{i})
        [path name ext] = fileparts(sorted_names{i});
        
        if (strcmp(ext,'.tif'))
            filecount = filecount+1;
            fileindices = [fileindices i];
        end
    end
end

filecount 
if filecount > 0
    files = cell(filecount,1);
    for i=1:filecount
        files{i} = sorted_names{fileindices(i)};
    end
else
    files = {};
end

nums_after_img=zeros(1,length(files));

for i=1:length(files)
    
    %find img and .tif end and start
    loc1=findstr(files{i},'g');
    loc2=findstr(files{i},'.');
    
    %store filestring in tmp variable and convert to double
    tmp=files{i};
    nums_after_img(1,i)=str2double(tmp(loc1+1:loc2-1));
   
end
    
files

filesnew=[char(files) nums_after_img'];

char_size=size(filesnew,2);  

filesnew=sortrows(filesnew,char_size);

files=cellstr(filesnew(:,1:char_size-1))  

handles.files=files;

guidata(hObject,handles);

%%%



% Get/generate some valuable context

handles.variables.theFolder    = cd;              % current folder is active folder
%temp = dir('*.tif');
handles.variables.nrOfFrames   = length(evalin('base','firstFrame:lastFrame'));    % get number of image files

step=1/((handles.variables.nrOfFrames)-1);
 set(handles.navigation_slider,'Value',1);
set(handles.navigation_slider,'Min', 1);
set(handles.navigation_slider,'Max', handles.variables.nrOfFrames);
set(handles.navigation_slider,'SliderStep',[step step]);

handles.variables.tracesObject = open('tracesobject.mat');

handles.variables.currentFrame = evalin('base', 'firstFrame');
handles.variables.firstFrame   = 1;
handles.variables.lastFrame    = 2;

handles.variables.first        = evalin('base', 'firstFrame');
handles.variables.last         = evalin('base',  'lastFrame');
handles.variables.theImg       = imread(handles.files{handles.variables.currentFrame});
%%%
hold on
image(handles.variables.theImg);
colormap(gray(256));

scatter(handles.variables.tracesObject.tracesObject.fplFinal(handles.variables.first,1),handles.variables.tracesObject.tracesObject.fplFinal(handles.variables.first,2),'*c')
scatter(handles.variables.tracesObject.tracesObject.fprFinal(handles.variables.first,1),handles.variables.tracesObject.tracesObject.fprFinal(handles.variables.first,2),'*r')
scatter(handles.variables.tracesObject.tracesObject.hplFinal(handles.variables.first,1),handles.variables.tracesObject.tracesObject.hplFinal(handles.variables.first,2),'*g')
scatter(handles.variables.tracesObject.tracesObject.hprFinal(handles.variables.first,1),handles.variables.tracesObject.tracesObject.hprFinal(handles.variables.first,2),'*b')
scatter(handles.variables.tracesObject.tracesObject.tail(handles.variables.first,1),handles.variables.tracesObject.tracesObject.tail(handles.variables.first,2), 25, 'om')

axis([1 512 1 256]);
axis ij
axis off

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes checkClassification wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = checkClassification_OutputFcn(hObject, eventdata, handles) 
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

assignin('base','checkedTracesObject',handles.variables.tracesObject.tracesObject)

%save([handle.variables.folder filesep 'finalResult.mat'], 'checkedTracesObject');

delete(handles.figure1)

% --- Executes on button press in playButton. (= draw result)
function playButton_Callback(hObject, eventdata, handles)
% hObject    handle to playButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

for n = handles.variables.firstFrame:handles.variables.lastFrame
    
    % do the whole update variables...
    handles.variables.currentFrame = n + handles.variables.first - 1;
       
    % ...update indicator string...
    set(handles.text2, 'String', ['Frame: ' int2str(handles.variables.currentFrame - handles.variables.first + 1) '/' int2str(handles.variables.nrOfFrames)]);
    
    % ...load image...
    iterator=(n + handles.variables.first - 2);

    handles.variables.theImg     = imread(char(handles.files(iterator)));
    % ...additional data...
    fpl  = handles.variables.tracesObject.tracesObject.fplFinal(n + handles.variables.first - 1,1:2);
    fpr  = handles.variables.tracesObject.tracesObject.fprFinal(n + handles.variables.first - 1,1:2);
    hpl  = handles.variables.tracesObject.tracesObject.hplFinal(n + handles.variables.first - 1,1:2);
    hpr  = handles.variables.tracesObject.tracesObject.hprFinal(n + handles.variables.first - 1,1:2);
    tail = handles.variables.tracesObject.tracesObject.tail(n + handles.variables.first - 1,1:2);
        
    % ... and draw stuff thang.
    cla
    
    hold on
        
    image(handles.variables.theImg)
    scatter( fpl(1), fpl(2),'*c')
    scatter( fpr(1), fpr(2),'*r')
    scatter( hpl(1), hpl(2),'*g')
    scatter( hpr(1), hpr(2),'*b')
    scatter(tail(1),tail(2), 25,'om');
        
    hold off
        
    axis([1 512 1 256])
    axis ij
    axis off
        
    % don't forget to pause afterwards
    pause(0.02);
        
    % and update the objects
    guidata(handles.output,handles);
        
end

% --- Executes on button press in nextButton.
function nextButton_Callback(hObject, eventdata, handles)
% hObject    handle to nextButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
targetFrame = handles.variables.currentFrame + 1;

if targetFrame > (handles.variables.last)
    targetFrame = handles.variables.currentFrame;
else
    handles.variables.currentFrame = targetFrame;
end

set(handles.text2, 'String', ['Frame: ' int2str(targetFrame - handles.variables.first + 1) '/' int2str(handles.variables.nrOfFrames)]);
        
handles.variables.theImg     = imread(handles.files{targetFrame-1});

fpl  = handles.variables.tracesObject.tracesObject.fplFinal(targetFrame,1:2);
fpr  = handles.variables.tracesObject.tracesObject.fprFinal(targetFrame,1:2);
hpl  = handles.variables.tracesObject.tracesObject.hplFinal(targetFrame,1:2);
hpr  = handles.variables.tracesObject.tracesObject.hprFinal(targetFrame,1:2);
tail = handles.variables.tracesObject.tracesObject.tail(targetFrame,1:2);

cla
hold on
        
image(handles.variables.theImg)
scatter( fpl(1), fpl(2),'*c')
scatter( fpr(1), fpr(2),'*r')
scatter( hpl(1), hpl(2),'*g')
scatter( hpr(1), hpr(2),'*b')
scatter(tail(1),tail(2), 25, 'om')
        
hold off
        
axis([1 512 1 256])
axis ij
axis off

guidata(handles.output,handles);



% --- Executes on button press in backButton.
function backButton_Callback(hObject, eventdata, handles)
% hObject    handle to backButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
targetFrame = handles.variables.currentFrame - 1;

if targetFrame < handles.variables.first
    targetFrame = handles.variables.currentFrame;
else
    handles.variables.currentFrame = targetFrame;
end

set(handles.text2, 'String', ['Frame: ' int2str(targetFrame - handles.variables.first + 1) '/' int2str(handles.variables.nrOfFrames)]);
        
handles.variables.theImg     = imread(handles.files{targetFrame-1});

fpl  = handles.variables.tracesObject.tracesObject.fplFinal(targetFrame,1:2);
fpr  = handles.variables.tracesObject.tracesObject.fprFinal(targetFrame,1:2);
hpl  = handles.variables.tracesObject.tracesObject.hplFinal(targetFrame,1:2);
hpr  = handles.variables.tracesObject.tracesObject.hprFinal(targetFrame,1:2);
tail = handles.variables.tracesObject.tracesObject.tail(targetFrame,1:2);

cla
hold on
        
image(handles.variables.theImg)
scatter( fpl(1), fpl(2),'*c')
scatter( fpr(1), fpr(2),'*r')
scatter( hpl(1), hpl(2),'*g')
scatter( hpr(1), hpr(2),'*b')
scatter(tail(1),tail(2), 25, 'om')
        
hold off
        
axis([1 512 1 256])
axis ij
axis off

guidata(handles.output,handles);

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1
% contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

popup_sel_index = get(handles.popupmenu1, 'Value');
switch popup_sel_index
    case 1 % Left front
        % store value at appropriate place
        handles.variables.tracesObject.tracesObject.fplFinal(handles.variables.currentFrame,:) = [NaN NaN NaN];
        
    case 2 % Right front
        % store value at appropriate place
        handles.variables.tracesObject.tracesObject.fprFinal(handles.variables.currentFrame,:) = [NaN NaN NaN];
        
    case 3 % Left hind
        % store value at appropriate place
        handles.variables.tracesObject.tracesObject.hplFinal(handles.variables.currentFrame,:) = [NaN NaN NaN];
        
    case 4 % Right hind
        % store value at appropriate place
        handles.variables.tracesObject.tracesObject.hprFinal(handles.variables.currentFrame,:) = [NaN NaN NaN];
        
    case 5 % Tail
        % store value at appropriate place
        handles.variables.tracesObject.tracesObject.tail(handles.variables.currentFrame,:)     = [NaN NaN NaN];
end

cla

hold on

image(handles.variables.theImg)
scatter(handles.variables.tracesObject.tracesObject.fplFinal(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.fplFinal(handles.variables.currentFrame,2),'*c')
scatter(handles.variables.tracesObject.tracesObject.fprFinal(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.fprFinal(handles.variables.currentFrame,2),'*r')
scatter(handles.variables.tracesObject.tracesObject.hplFinal(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.hplFinal(handles.variables.currentFrame,2),'*g')
scatter(handles.variables.tracesObject.tracesObject.hprFinal(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.hprFinal(handles.variables.currentFrame,2),'*b')
scatter(handles.variables.tracesObject.tracesObject.tail(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.tail(handles.variables.currentFrame,2), 25, 'om')

hold off

axis([1 512 1 256]);
axis ij
axis off

% save updated data
guidata(handles.output,handles);

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'Left front paw (CYAN)', 'Right front paw (RED)', 'Left hind paw (GREEN)', 'Right hind paw (BLUE)', 'Tail (PINK)'});


% --- Executes on button press in jumpbackButton.
function jumpbackButton_Callback(hObject, eventdata, handles)
% hObject    handle to jumpbackButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
targetFrame = handles.variables.currentFrame - 10;

if targetFrame < handles.variables.first
    targetFrame = handles.variables.currentFrame;
else
    handles.variables.currentFrame = targetFrame;
end

set(handles.text2, 'String', ['Frame: ' int2str(targetFrame - handles.variables.first + 1) '/' int2str(handles.variables.nrOfFrames)]);
        
handles.variables.theImg     = imread(handles.files{targetFrame-1});
    
fpl  = handles.variables.tracesObject.tracesObject.fplFinal(targetFrame,1:2);
fpr  = handles.variables.tracesObject.tracesObject.fprFinal(targetFrame,1:2);
hpl  = handles.variables.tracesObject.tracesObject.hplFinal(targetFrame,1:2);
hpr  = handles.variables.tracesObject.tracesObject.hprFinal(targetFrame,1:2);
tail = handles.variables.tracesObject.tracesObject.tail(targetFrame,1:2);

cla
hold on
        
image(handles.variables.theImg)
scatter( fpl(1), fpl(2),'*c')
scatter( fpr(1), fpr(2),'*r')
scatter( hpl(1), hpl(2),'*g')
scatter( hpr(1), hpr(2),'*b')
scatter(tail(1),tail(2), 25, 'om')
        
hold off
        
axis([1 512 1 256])
axis ij
axis off

guidata(handles.output,handles);


% --- Executes on button press in jumpnextFrame.
function jumpnextFrame_Callback(hObject, eventdata, handles)
% hObject    handle to jumpnextFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
targetFrame = handles.variables.currentFrame + 10;

if targetFrame > handles.variables.last
    targetFrame = handles.variables.currentFrame;
else
    handles.variables.currentFrame = targetFrame;
end

set(handles.text2, 'String', ['Frame: ' int2str(targetFrame - handles.variables.first + 1) '/' int2str(handles.variables.nrOfFrames)]);
        
handles.variables.theImg     = imread(handles.files{targetFrame-1});
    
fpl  = handles.variables.tracesObject.tracesObject.fplFinal(targetFrame,1:2);
fpr  = handles.variables.tracesObject.tracesObject.fprFinal(targetFrame,1:2);
hpl  = handles.variables.tracesObject.tracesObject.hplFinal(targetFrame,1:2);
hpr  = handles.variables.tracesObject.tracesObject.hprFinal(targetFrame,1:2);
tail = handles.variables.tracesObject.tracesObject.tail(targetFrame,1:2);

cla
hold on
        
image(handles.variables.theImg)
scatter( fpl(1), fpl(2),'*c')
scatter( fpr(1), fpr(2),'*r')
scatter( hpl(1), hpl(2),'*g')
scatter( hpr(1), hpr(2),'*b')
scatter(tail(1),tail(2), 25, 'om')
        
hold off
        
axis([1 512 1 256])
axis ij
axis off

guidata(handles.output,handles);



function firstFrame_Callback(hObject, eventdata, handles)
% hObject    handle to firstFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of firstFrame as text
%        str2double(get(hObject,'String')) returns contents of firstFrame as a double
targetFrame = str2double(get(hObject, 'String'));
if isnan(targetFrame)
    set(hObject, 'String', 0);
    errordlg('Input must be an integer','Error');
end

targetFrame = targetFrame + handles.variables.first - 1;

if targetFrame > handles.variables.last
    targetFrame = handles.variables.last;
end

if targetFrame >= handles.variables.first
    handles.variables.firstFrame = targetFrame - handles.variables.first + 1;
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

% Hints: get(hObject,'String') returns contents of lastFrame as text
%        str2double(get(hObject,'String')) returns contents of lastFrame as a double
targetFrame = str2double(get(hObject, 'String'));
if isnan(targetFrame)
    set(hObject, 'String', 0);
    errordlg('Input must be an integer','Error');
end

if targetFrame < handles.variables.firstFrame
    targetFrame = handles.variables.firstFrame;
end

targetFrame = targetFrame + handles.variables.first - 1;

if targetFrame > handles.variables.last
    handles.variables.lastFrame = handles.variables.last;
    set(hObject, 'String', handles.variables.nrOfFrames);
else
    handles.variables.lastFrame = targetFrame - handles.variables.first + 1;
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



function jump2frame_Callback(hObject, eventdata, handles)
% hObject    handle to jump2frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of jump2frame as text
%        str2double(get(hObject,'String')) returns contents of jump2frame as a double
targetFrame = str2double(get(hObject, 'String')) + handles.variables.first - 1;
if isnan(targetFrame)
    set(hObject, 'String', 0);
    errordlg('Input must be an integer','Error');
end

if targetFrame > handles.variables.last
    set(hObject, 'String', (handles.variables.last - handles.variables.first + 1))
    targetFrame = handles.variables.last - handles.variables.first + 1;
    errordlg('Target frame out of bounds.','Error');
else
    handles.variables.currentFrame = targetFrame;
end

set(handles.text2, 'String', ['Frame: ' int2str(targetFrame - handles.variables.first + 1) '/' int2str(handles.variables.nrOfFrames)]);
        
handles.variables.theImg     = imread(handles.files{targetFrame - 1});

fpl  = handles.variables.tracesObject.tracesObject.fplFinal(targetFrame,1:2);
fpr  = handles.variables.tracesObject.tracesObject.fprFinal(targetFrame,1:2);
hpl  = handles.variables.tracesObject.tracesObject.hplFinal(targetFrame,1:2);
hpr  = handles.variables.tracesObject.tracesObject.hprFinal(targetFrame,1:2);
tail = handles.variables.tracesObject.tracesObject.tail(targetFrame,1:2);

cla
hold on
        
image(handles.variables.theImg)
scatter( fpl(1), fpl(2),'*c')
scatter( fpr(1), fpr(2),'*r')
scatter( hpl(1), hpl(2),'*g')
scatter( hpr(1), hpr(2),'*b')
scatter(tail(1),tail(2), 25, 'om')
        
hold off
        
axis([1 512 1 256])
axis ij
axis off

guidata(handles.output,handles);

% --- Executes during object creation, after setting all properties.
function jump2frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to jump2frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in remove_tail_pink.
function remove_tail_pink_Callback(hObject, eventdata, handles)
% hObject    handle to remove_tail_pink (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.variables.tracesObject.tracesObject.tail(handles.variables.currentFrame,:)     = [NaN NaN NaN];
guidata(hObject,handles);

cla;

hold on

image(handles.variables.theImg)
scatter(handles.variables.tracesObject.tracesObject.fplFinal(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.fplFinal(handles.variables.currentFrame,2),'*c')
scatter(handles.variables.tracesObject.tracesObject.fprFinal(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.fprFinal(handles.variables.currentFrame,2),'*r')
scatter(handles.variables.tracesObject.tracesObject.hplFinal(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.hplFinal(handles.variables.currentFrame,2),'*g')
scatter(handles.variables.tracesObject.tracesObject.hprFinal(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.hprFinal(handles.variables.currentFrame,2),'*b')
scatter(handles.variables.tracesObject.tracesObject.tail(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.tail(handles.variables.currentFrame,2), 25, 'om')

hold off

axis([1 512 1 256]);
axis ij
axis off

targetFrame = handles.variables.currentFrame + 1;

if targetFrame > (handles.variables.last)
    targetFrame = handles.variables.currentFrame;
else
    handles.variables.currentFrame = targetFrame;
end

set(handles.text2, 'String', ['Frame: ' int2str(targetFrame - handles.variables.first + 1) '/' int2str(handles.variables.nrOfFrames)]);
        
handles.variables.theImg     = imread(handles.files{targetFrame-1});

fpl  = handles.variables.tracesObject.tracesObject.fplFinal(targetFrame,1:2);
fpr  = handles.variables.tracesObject.tracesObject.fprFinal(targetFrame,1:2);
hpl  = handles.variables.tracesObject.tracesObject.hplFinal(targetFrame,1:2);
hpr  = handles.variables.tracesObject.tracesObject.hprFinal(targetFrame,1:2);
tail = handles.variables.tracesObject.tracesObject.tail(targetFrame,1:2);

cla
hold on
        
image(handles.variables.theImg)
scatter( fpl(1), fpl(2),'*c')
scatter( fpr(1), fpr(2),'*r')
scatter( hpl(1), hpl(2),'*g')
scatter( hpr(1), hpr(2),'*b')
scatter(tail(1),tail(2), 25, 'om')
        
hold off
        
axis([1 512 1 256])
axis ij
axis off

guidata(handles.output,handles);



% --- Executes on button press in remove_hlp_green.
function remove_hlp_green_Callback(hObject, eventdata, handles)
% hObject    handle to remove_hlp_green (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.variables.tracesObject.tracesObject.hplFinal(handles.variables.currentFrame,:) = [NaN NaN NaN];
guidata(hObject,handles);

cla

hold on

image(handles.variables.theImg)
scatter(handles.variables.tracesObject.tracesObject.fplFinal(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.fplFinal(handles.variables.currentFrame,2),'*c')
scatter(handles.variables.tracesObject.tracesObject.fprFinal(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.fprFinal(handles.variables.currentFrame,2),'*r')
scatter(handles.variables.tracesObject.tracesObject.hplFinal(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.hplFinal(handles.variables.currentFrame,2),'*g')
scatter(handles.variables.tracesObject.tracesObject.hprFinal(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.hprFinal(handles.variables.currentFrame,2),'*b')
scatter(handles.variables.tracesObject.tracesObject.tail(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.tail(handles.variables.currentFrame,2), 25, 'om')

hold off

axis([1 512 1 256]);
axis ij
axis off

targetFrame = handles.variables.currentFrame + 1;

if targetFrame > (handles.variables.last)
    targetFrame = handles.variables.currentFrame;
else
    handles.variables.currentFrame = targetFrame;
end

set(handles.text2, 'String', ['Frame: ' int2str(targetFrame - handles.variables.first + 1) '/' int2str(handles.variables.nrOfFrames)]);
        
handles.variables.theImg     = imread(handles.files{targetFrame-1});


fpl  = handles.variables.tracesObject.tracesObject.fplFinal(targetFrame,1:2);
fpr  = handles.variables.tracesObject.tracesObject.fprFinal(targetFrame,1:2);
hpl  = handles.variables.tracesObject.tracesObject.hplFinal(targetFrame,1:2);
hpr  = handles.variables.tracesObject.tracesObject.hprFinal(targetFrame,1:2);
tail = handles.variables.tracesObject.tracesObject.tail(targetFrame,1:2);

cla
hold on
        
image(handles.variables.theImg)
scatter( fpl(1), fpl(2),'*c')
scatter( fpr(1), fpr(2),'*r')
scatter( hpl(1), hpl(2),'*g')
scatter( hpr(1), hpr(2),'*b')
scatter(tail(1),tail(2), 25, 'om')
        
hold off
        
axis([1 512 1 256])
axis ij
axis off

guidata(handles.output,handles);


% --- Executes on button press in remove_hrp_blue.
function remove_hrp_blue_Callback(hObject, eventdata, handles)
% hObject    handle to remove_hrp_blue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.variables.tracesObject.tracesObject.hprFinal(handles.variables.currentFrame,:) = [NaN NaN NaN];
guidata(hObject,handles);

cla

hold on

image(handles.variables.theImg)
scatter(handles.variables.tracesObject.tracesObject.fplFinal(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.fplFinal(handles.variables.currentFrame,2),'*c')
scatter(handles.variables.tracesObject.tracesObject.fprFinal(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.fprFinal(handles.variables.currentFrame,2),'*r')
scatter(handles.variables.tracesObject.tracesObject.hplFinal(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.hplFinal(handles.variables.currentFrame,2),'*g')
scatter(handles.variables.tracesObject.tracesObject.hprFinal(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.hprFinal(handles.variables.currentFrame,2),'*b')
scatter(handles.variables.tracesObject.tracesObject.tail(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.tail(handles.variables.currentFrame,2), 25, 'om')

hold off

axis([1 512 1 256]);
axis ij
axis off


targetFrame = handles.variables.currentFrame + 1;

if targetFrame > (handles.variables.last)
    targetFrame = handles.variables.currentFrame;
else
    handles.variables.currentFrame = targetFrame;
end

set(handles.text2, 'String', ['Frame: ' int2str(targetFrame - handles.variables.first + 1) '/' int2str(handles.variables.nrOfFrames)]);
        
handles.variables.theImg     = imread(handles.files{targetFrame-1});

fpl  = handles.variables.tracesObject.tracesObject.fplFinal(targetFrame,1:2);
fpr  = handles.variables.tracesObject.tracesObject.fprFinal(targetFrame,1:2);
hpl  = handles.variables.tracesObject.tracesObject.hplFinal(targetFrame,1:2);
hpr  = handles.variables.tracesObject.tracesObject.hprFinal(targetFrame,1:2);
tail = handles.variables.tracesObject.tracesObject.tail(targetFrame,1:2);

cla
hold on
        
image(handles.variables.theImg)
scatter( fpl(1), fpl(2),'*c')
scatter( fpr(1), fpr(2),'*r')
scatter( hpl(1), hpl(2),'*g')
scatter( hpr(1), hpr(2),'*b')
scatter(tail(1),tail(2), 25, 'om')
        
hold off
        
axis([1 512 1 256])
axis ij
axis off

guidata(handles.output,handles);


% --- Executes on button press in remove_flp_cyan.
function remove_flp_cyan_Callback(hObject, eventdata, handles)
% hObject    handle to remove_flp_cyan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.variables.tracesObject.tracesObject.fplFinal(handles.variables.currentFrame,:) = [NaN NaN NaN];
guidata(hObject,handles);

cla

hold on

image(handles.variables.theImg)
scatter(handles.variables.tracesObject.tracesObject.fplFinal(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.fplFinal(handles.variables.currentFrame,2),'*c')
scatter(handles.variables.tracesObject.tracesObject.fprFinal(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.fprFinal(handles.variables.currentFrame,2),'*r')
scatter(handles.variables.tracesObject.tracesObject.hplFinal(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.hplFinal(handles.variables.currentFrame,2),'*g')
scatter(handles.variables.tracesObject.tracesObject.hprFinal(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.hprFinal(handles.variables.currentFrame,2),'*b')
scatter(handles.variables.tracesObject.tracesObject.tail(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.tail(handles.variables.currentFrame,2), 25, 'om')

hold off

axis([1 512 1 256]);
axis ij
axis off

targetFrame = handles.variables.currentFrame + 1;

if targetFrame > (handles.variables.last)
    targetFrame = handles.variables.currentFrame;
else
    handles.variables.currentFrame = targetFrame;
end

set(handles.text2, 'String', ['Frame: ' int2str(targetFrame - handles.variables.first + 1) '/' int2str(handles.variables.nrOfFrames)]);
        
handles.variables.theImg     = imread(handles.files{targetFrame-1});

fpl  = handles.variables.tracesObject.tracesObject.fplFinal(targetFrame,1:2);
fpr  = handles.variables.tracesObject.tracesObject.fprFinal(targetFrame,1:2);
hpl  = handles.variables.tracesObject.tracesObject.hplFinal(targetFrame,1:2);
hpr  = handles.variables.tracesObject.tracesObject.hprFinal(targetFrame,1:2);
tail = handles.variables.tracesObject.tracesObject.tail(targetFrame,1:2);

cla
hold on
        
image(handles.variables.theImg)
scatter( fpl(1), fpl(2),'*c')
scatter( fpr(1), fpr(2),'*r')
scatter( hpl(1), hpl(2),'*g')
scatter( hpr(1), hpr(2),'*b')
scatter(tail(1),tail(2), 25, 'om')
        
hold off
        
axis([1 512 1 256])
axis ij
axis off

guidata(handles.output,handles);


% --- Executes on button press in remove_frp_red.
function remove_frp_red_Callback(hObject, eventdata, handles)
% hObject    handle to remove_frp_red (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.variables.tracesObject.tracesObject.fprFinal(handles.variables.currentFrame,:) = [NaN NaN NaN];
guidata(hObject, handles);

cla

hold on

image(handles.variables.theImg)
scatter(handles.variables.tracesObject.tracesObject.fplFinal(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.fplFinal(handles.variables.currentFrame,2),'*c')
scatter(handles.variables.tracesObject.tracesObject.fprFinal(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.fprFinal(handles.variables.currentFrame,2),'*r')
scatter(handles.variables.tracesObject.tracesObject.hplFinal(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.hplFinal(handles.variables.currentFrame,2),'*g')
scatter(handles.variables.tracesObject.tracesObject.hprFinal(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.hprFinal(handles.variables.currentFrame,2),'*b')
scatter(handles.variables.tracesObject.tracesObject.tail(handles.variables.currentFrame,1),handles.variables.tracesObject.tracesObject.tail(handles.variables.currentFrame,2), 25, 'om')

hold off

axis([1 512 1 256]);
axis ij
axis off

targetFrame = handles.variables.currentFrame + 1;

if targetFrame > (handles.variables.last)
    targetFrame = handles.variables.currentFrame;
else
    handles.variables.currentFrame = targetFrame;
end

set(handles.text2, 'String', ['Frame: ' int2str(targetFrame - handles.variables.first + 1) '/' int2str(handles.variables.nrOfFrames)]);
        
handles.variables.theImg     = imread(handles.files{targetFrame-1});

fpl  = handles.variables.tracesObject.tracesObject.fplFinal(targetFrame,1:2);
fpr  = handles.variables.tracesObject.tracesObject.fprFinal(targetFrame,1:2);
hpl  = handles.variables.tracesObject.tracesObject.hplFinal(targetFrame,1:2);
hpr  = handles.variables.tracesObject.tracesObject.hprFinal(targetFrame,1:2);
tail = handles.variables.tracesObject.tracesObject.tail(targetFrame,1:2);

cla
hold on
        
image(handles.variables.theImg)
scatter( fpl(1), fpl(2),'*c')
scatter( fpr(1), fpr(2),'*r')
scatter( hpl(1), hpl(2),'*g')
scatter( hpr(1), hpr(2),'*b')
scatter(tail(1),tail(2), 25, 'om')
        
hold off
        
axis([1 512 1 256])
axis ij
axis off

guidata(handles.output,handles);


% --- Executes on slider movement.
function navigation_slider_Callback(hObject, eventdata, handles)
% hObject    handle to navigation_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%
slider_position = get(hObject,'Value');

if(slider_position==0)
    slider_position=1;
    curpos=1;
else
    curpos=round(slider_position);
end

if(slider_position > handles.variables.last)
    slider_position = handles.variables.currentFrame;
else
    handles.variables.currentFrame = slider_position;
end

set(handles.text2, 'String', ['Frame: ' int2str(curpos - handles.variables.first + 1) '/' int2str(handles.variables.nrOfFrames)]);
 
if(curpos>1)
    handles.variables.theImg     = imread(handles.files{curpos-1});
end

fpl  = handles.variables.tracesObject.tracesObject.fplFinal(curpos,1:2);
fpr  = handles.variables.tracesObject.tracesObject.fprFinal(curpos,1:2);
hpl  = handles.variables.tracesObject.tracesObject.hplFinal(curpos,1:2);
hpr  = handles.variables.tracesObject.tracesObject.hprFinal(curpos,1:2);
tail = handles.variables.tracesObject.tracesObject.tail(curpos,1:2);

cla;
hold on
        
image(handles.variables.theImg)
scatter( fpl(1), fpl(2),'*c')
scatter( fpr(1), fpr(2),'*r')
scatter( hpl(1), hpl(2),'*g')
scatter( hpr(1), hpr(2),'*b')
scatter(tail(1),tail(2), 25, 'om')
hold off        
axis([1 512 1 256])
axis ij
axis off
drawnow();


guidata(handles.output,handles);


% --- Executes during object creation, after setting all properties.
function navigation_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to navigation_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% slider_increment = 1/handles.variables.nrOfFrames;
% set(handles.navigation_slider,'SliderStep',[1 handles.variables.nrOfFrames]);
