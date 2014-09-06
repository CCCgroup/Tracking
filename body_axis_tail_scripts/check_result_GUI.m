function varargout = check_result_GUI(varargin)
% CHECK_RESULT_GUI M-file for check_result_GUI.fig
%      CHECK_RESULT_GUI, by itself, creates a new CHECK_RESULT_GUI or raises the existing
%      singleton*.
%
%      H = CHECK_RESULT_GUI returns the handle to a new CHECK_RESULT_GUI or the handle to
%      the existing singleton*.
%
%      CHECK_RESULT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHECK_RESULT_GUI.M with the given input arguments.
%
%      CHECK_RESULT_GUI('Property','Value',...) creates a new CHECK_RESULT_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before check_result_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to check_result_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help check_result_GUI

% Last Modified by GUIDE v2.5 11-Mar-2013 14:05:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @check_result_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @check_result_GUI_OutputFcn, ...
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


% --- Executes just before check_result_GUI is made visible.
function check_result_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to check_result_GUI (see VARARGIN)

% Choose default command line output for check_result_GUI
handles.output = hObject;

% Get/generate some valuable context

handles.variables.theFolder    = cd;
handles.variables.filelist     = dir('*.tif');
handles.variables.nrOfFrames   = length(handles.variables.filelist);
set(handles.text2,'String',['Frame: ' int2str(1) '/' int2str(handles.variables.nrOfFrames)]);
load('automated_clustering_results.mat')
load('headloc.mat')
handles.variables.head         = head_coords;
handles.variables.the_objects  = the_objects;

tempclust = metaclusters;

for n = 1:4
        
    if strcmp('left front paw',metaclusters(n).limb)
        tempclust(1) = metaclusters(n);
    end
    if strcmp('right front paw',metaclusters(n).limb)
        tempclust(2) = metaclusters(n);
    end
    if strcmp('left hind paw',metaclusters(n).limb)
        tempclust(3) = metaclusters(n);
    end
    if strcmp('right hind paw',metaclusters(n).limb)
        tempclust(4) = metaclusters(n);
    end
       
end

handles.variables.metaclusters = tempclust;
handles.variables.plot_colors  = { '*c','sr','dg','b' };

handles.variables.currentFrame = 1;
handles.variables.firstFrame   = 1;
handles.variables.lastFrame    = 2;

% handles.variables.first        = evalin('base', 'firstFrame');
% handles.variables.last         = evalin('base',  'lastFrame');

handles.variables.theImg       = imread([handles.variables.theFolder filesep handles.variables.filelist(1).name]);

hold on
image(handles.variables.theImg);
colormap(gray(256));

for n = 1:length(handles.variables.metaclusters)
    
    if ~isempty(handles.variables.metaclusters(n).objects)
        
        this_frame = handles.variables.metaclusters(n).objects(handles.variables.metaclusters(n).objects(:,4) == 1);
        if ~isempty(this_frame)
        scatter(this_frame(1)+handles.variables.head(1),this_frame(2)+handles.variables.head(2),handles.variables.plot_colors{n});
        end
        
    end
    
end

axis([1 512 1 256]);
axis ij
axis off

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes check_result_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = check_result_GUI_OutputFcn(hObject, eventdata, handles) 
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
the_objects  = handles.variables.the_objects;
metaclusters = handles.variables.metaclusters;
save('checked_results.mat','the_objects','metaclusters');

delete(handles.figure1)

% --- Executes on button press in playButton. (= draw result)
function playButton_Callback(hObject, eventdata, handles)
% hObject    handle to playButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

for n = handles.variables.firstFrame:handles.variables.lastFrame
    
    % do the whole update variables...
    handles.variables.currentFrame = n;% + handles.variables.first - 1;
       
    % ...update indicator string...
    set(handles.text2, 'String', ['Frame: ' int2str(n) '/' int2str(handles.variables.nrOfFrames)]);%int2str(handles.variables.currentFrame - handles.variables.first + 1) '/' int2str(handles.variables.nrOfFrames)]);
    
    % ...load image...
    handles.variables.theImg     = imread([handles.variables.theFolder filesep handles.variables.filelist(n).name]);%(n + handles.variables.first - 2) '.tif']);

    % ... and draw stuff thang.
    cla
    image(handles.variables.theImg)
    hold on
    for q = 1:4
    
        if ~isempty(handles.variables.metaclusters(q).objects)
        
            this_frame = handles.variables.metaclusters(q).objects(handles.variables.metaclusters(q).objects(:,4) == n,:);
            if ~isempty(this_frame)
                scatter(this_frame(1)+handles.variables.head(1),this_frame(2)+handles.variables.head(2),handles.variables.plot_colors{q});
            end
        end
    end
        
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

if targetFrame > (handles.variables.nrOfFrames)
    targetFrame = handles.variables.currentFrame;
else
    handles.variables.currentFrame = targetFrame;
end

set(handles.text2, 'String', ['Frame: ' int2str(targetFrame) '/' int2str(handles.variables.nrOfFrames)]);
        
handles.variables.theImg     = imread([handles.variables.theFolder filesep handles.variables.filelist(targetFrame).name]);



cla
image(handles.variables.theImg)
hold on
for q = 1:4
    
    if ~isempty(handles.variables.metaclusters(q).objects)
        
        this_frame = handles.variables.metaclusters(q).objects(handles.variables.metaclusters(q).objects(:,4) == targetFrame,:);
        if ~isempty(this_frame)
            scatter(this_frame(1)+handles.variables.head(1),this_frame(2)+handles.variables.head(2),handles.variables.plot_colors{q});
        end
    end
end
        
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

if targetFrame < 1
    targetFrame = handles.variables.currentFrame;
else
    handles.variables.currentFrame = targetFrame;
end

set(handles.text2, 'String', ['Frame: ' int2str(targetFrame) '/' int2str(handles.variables.nrOfFrames)]);
        
handles.variables.theImg     = imread([handles.variables.theFolder filesep handles.variables.filelist(targetFrame).name]);

cla
image(handles.variables.theImg)
hold on
for q = 1:4
    
    if ~isempty(handles.variables.metaclusters(q).objects)
        
        this_frame = handles.variables.metaclusters(q).objects(handles.variables.metaclusters(q).objects(:,4) == targetFrame,:);
        if ~isempty(this_frame)
            scatter(this_frame(1)+handles.variables.head(1),this_frame(2)+handles.variables.head(2),handles.variables.plot_colors{q});
        end
    end
end
        
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
%        handles.variables.tracesObject.tracesObject.fplFinal(handles.variables.currentFrame,:) = [NaN NaN NaN];
handles.variables.metaclusters(popup_sel_index).objects(handles.variables.metaclusters(popup_sel_index).objects(:,4) == handles.variables.currentFrame,:) = [];
        
    case 2 % Right front
        % store value at appropriate place
%        handles.variables.tracesObject.tracesObject.fprFinal(handles.variables.currentFrame,:) = [NaN NaN NaN];
handles.variables.metaclusters(popup_sel_index).objects(handles.variables.metaclusters(popup_sel_index).objects(:,4) == handles.variables.currentFrame,:) = [];
        
    case 3 % Left hind
        % store value at appropriate place
%        handles.variables.tracesObject.tracesObject.hplFinal(handles.variables.currentFrame,:) = [NaN NaN NaN];
handles.variables.metaclusters(popup_sel_index).objects(handles.variables.metaclusters(popup_sel_index).objects(:,4) == handles.variables.currentFrame,:) = [];
        
    case 4 % Right hind
        % store value at appropriate place
%        handles.variables.tracesObject.tracesObject.hprFinal(handles.variables.currentFrame,:) = [NaN NaN NaN];
handles.variables.metaclusters(popup_sel_index).objects(handles.variables.metaclusters(popup_sel_index).objects(:,4) == handles.variables.currentFrame,:) = [];
        
end

cla
image(handles.variables.theImg)
hold on
for q = 1:4
    
    if ~isempty(handles.variables.metaclusters(q).objects)
        
        this_frame = handles.variables.metaclusters(q).objects(handles.variables.metaclusters(q).objects(:,4) == handles.variables.currentFrame,:);
        if ~isempty(this_frame)
            scatter(this_frame(1)+handles.variables.head(1),this_frame(2)+handles.variables.head(2),handles.variables.plot_colors{q});
        end
    end
end
        
hold off
        
axis([1 512 1 256])
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

set(hObject, 'String', {'Left front paw (CYAN)', 'Right front paw (RED)', 'Left hind paw (GREEN)', 'Right hind paw (BLUE)'});


% --- Executes on button press in jumpbackButton.
function jumpbackButton_Callback(hObject, eventdata, handles)
% hObject    handle to jumpbackButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
targetFrame = handles.variables.currentFrame - 10;

if targetFrame < 1
    targetFrame = 1;
end
handles.variables.currentFrame = targetFrame;

set(handles.text2, 'String', ['Frame: ' int2str(targetFrame) '/' int2str(handles.variables.nrOfFrames)]);
        
handles.variables.theImg     = imread([handles.variables.theFolder filesep handles.variables.filelist(targetFrame).name]);

cla
image(handles.variables.theImg)
hold on
for q = 1:4
    
    if ~isempty(handles.variables.metaclusters(q).objects)
        
        this_frame = handles.variables.metaclusters(q).objects(handles.variables.metaclusters(q).objects(:,4) == targetFrame,:);
        if ~isempty(this_frame)
            scatter(this_frame(1)+handles.variables.head(1),this_frame(2)+handles.variables.head(2),handles.variables.plot_colors{q});
        end
    end
end
        
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

if targetFrame > handles.variables.nrOfFrames
    targetFrame = handles.variables.nrOfFrames;
end

handles.variables.currentFrame = targetFrame;

set(handles.text2, 'String', ['Frame: ' int2str(targetFrame) '/' int2str(handles.variables.nrOfFrames)]);
        
handles.variables.theImg     = imread([handles.variables.theFolder filesep handles.variables.filelist(targetFrame).name]);

cla
image(handles.variables.theImg)
hold on
for q = 1:4
    
    if ~isempty(handles.variables.metaclusters(q).objects)
        
        this_frame = handles.variables.metaclusters(q).objects(handles.variables.metaclusters(q).objects(:,4) == targetFrame,:);
        if ~isempty(this_frame)
            scatter(this_frame(1)+handles.variables.head(1),this_frame(2)+handles.variables.head(2),handles.variables.plot_colors{q});
        end
    end
end
        
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
    set(hObject, 'String', 1);
    errordlg('Input must be an integer','Error');
end
handles.variables.firstFrame = targetFrame;
%targetFrame = targetFrame + handles.variables.first - 1;

if targetFrame > handles.variables.nrOfFrames
    targetFrame = handles.variables.nrOfFrames;
end

if ~(targetFrame >= 1)%handles.variables.first)
%     handles.variables.firstFrame = targetFrame - handles.variables.first + 1;
% else
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
handles.variables.lastFrame = targetFrame;
if targetFrame < handles.variables.firstFrame
    targetFrame = handles.variables.firstFrame;
end

%targetFrame = targetFrame + handles.variables.first - 1;
if targetFrame > handles.variables.nrOfFrames
    handles.variables.lastFrame = handles.variables.nrOfFrames;
    set(hObject, 'String', handles.variables.nrOfFrames);
end
% if targetFrame > handles.variables.last
%     handles.variables.lastFrame = handles.variables.last;
%     set(hObject, 'String', handles.variables.nrOfFrames);
% else
%     handles.variables.lastFrame = targetFrame - handles.variables.first + 1;
% end

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
targetFrame = str2double(get(hObject, 'String'));
if isnan(targetFrame)
    set(hObject, 'String', 0);
    errordlg('Input must be an integer','Error');
end

if targetFrame > handles.variables.nrOfFrames
    set(hObject, 'String', int2str(handles.variables.nrOfFrames))
    targetFrame = handles.variables.nrOfFrames;
    errordlg('Target frame out of bounds.','Error');
elseif targetFrame < 1
    set(hObject, 'String', int2str(1));
    targetFrame = 1;
    errordlg('Target frame out of bounds.','Error');
end

handles.variables.currentFrame = targetFrame;


set(handles.text2, 'String', ['Frame: ' int2str(targetFrame) '/' int2str(handles.variables.nrOfFrames)]);
        
handles.variables.theImg     = imread([handles.variables.theFolder filesep handles.variables.filelist(targetFrame).name]);

cla
image(handles.variables.theImg)
hold on
for q = 1:4
    
    if ~isempty(handles.variables.metaclusters(q).objects)
        
        this_frame = handles.variables.metaclusters(q).objects(handles.variables.metaclusters(q).objects(:,4) == targetFrame,:);
        if ~isempty(this_frame)
            scatter(this_frame(1)+handles.variables.head(1),this_frame(2)+handles.variables.head(2),handles.variables.plot_colors{q});
        end
    end
end
        
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
