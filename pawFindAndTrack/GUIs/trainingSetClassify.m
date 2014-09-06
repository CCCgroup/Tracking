function varargout = trainingSetClassify(varargin)
% TRAININGSETCLASSIFY MATLAB code for trainingSetClassify.fig
%      TRAININGSETCLASSIFY, by itself, creates a new TRAININGSETCLASSIFY or raises the existing
%      singleton*.
%
%      H = TRAININGSETCLASSIFY returns the handle to a new TRAININGSETCLASSIFY or the handle to
%      the existing singleton*.
%
%      TRAININGSETCLASSIFY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TRAININGSETCLASSIFY.M with the given input arguments.
%
%      TRAININGSETCLASSIFY('Property','Value',...) creates a new TRAININGSETCLASSIFY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before trainingSetClassify_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to trainingSetClassify_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help trainingSetClassify

% Last Modified by GUIDE v2.5 27-Mar-2012 17:56:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @trainingSetClassify_OpeningFcn, ...
                   'gui_OutputFcn',  @trainingSetClassify_OutputFcn, ...
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


% --- Executes just before trainingSetClassify is made visible.
function trainingSetClassify_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to trainingSetClassify (see VARARGIN)

% Choose default command line output for trainingSetClassify
handles.output = hObject;

% Set some variables to be used later...
handles.variables.folder        = cd;

handles.variables.output        = {};

%load objects.mat

handles.variables.currentFrame  = 1;  % start at the first processed frame
handles.variables.currentObject = 1;  % start at the first processed object

handles.variables.theSet        = evalin('base','trainFrames');
handles.variables.objects       = evalin('base','theObjects');

handles.variables.objectsInCurrentFrame = length(handles.variables.objects{handles.variables.theSet(1) - evalin('base', 'firstFrame') + 1});
handles.variables.theImg        = imread([handles.variables.folder filesep 'Paws' filesep 'paws' int2str(handles.variables.theSet(1)-1) '.tif']);

set(handles.text2, 'String', ['Frame: ' int2str(handles.variables.currentFrame) '/' int2str(length(handles.variables.theSet))]);

hold on

image(handles.variables.theImg)
colormap(gray(128))

scatter(handles.variables.objects{1}{1}.PixelList(:,1),handles.variables.objects{1}{1}.PixelList(:,2),'.r')

axis([1 512 1 256])
axis ij
axis off

hold off

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes trainingSetClassify wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = trainingSetClassify_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
axes(handles.axes1);
cla;

popup_sel_index = get(handles.popupmenu1, 'Value');

switch popup_sel_index
    case 1 % Left front
        % store value at appropriate place
        handles.variables.output{handles.variables.currentFrame}(handles.variables.currentObject) = 1;
        
    case 2 % Right front
        % store value at appropriate place
        handles.variables.output{handles.variables.currentFrame}(handles.variables.currentObject) = 2;
        
    case 3 % Left hind
        % store value at appropriate place
        handles.variables.output{handles.variables.currentFrame}(handles.variables.currentObject) = 3;
        
    case 4 % Right hind
        % store value at appropriate place
        handles.variables.output{handles.variables.currentFrame}(handles.variables.currentObject) = 4;
        
    case 5 % Tail
        % store value at appropriate place
        handles.variables.output{handles.variables.currentFrame}(handles.variables.currentObject) = 5;
        
    case 6 % Nothing
        % store value at appropriate place
        handles.variables.output{handles.variables.currentFrame}(handles.variables.currentObject) = 6;
        
end

% update current values
handles.variables.currentObject = handles.variables.currentObject + 1;
if handles.variables.currentObject > handles.variables.objectsInCurrentFrame
    handles.variables.currentObject = 1;
    handles.variables.currentFrame  = handles.variables.currentFrame + 1;
end

if handles.variables.currentFrame > length(handles.variables.theSet)
    % update the data
    guidata(handles.output,handles);
    % save the data
    assignin('base','trainingOutput',handles.variables.output)
    % exit GUI
    delete(handles.figure1)
else
    % get the new number of objects
    handles.variables.objectsInCurrentFrame = length(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1});
    % update the picture text
    set(handles.text2, 'String', ['Frame: ' int2str(handles.variables.currentFrame) '/' int2str(length(handles.variables.theSet))]);
    % load new image
    handles.variables.theImg = imread([handles.variables.folder filesep 'Paws' filesep 'paws' int2str(handles.variables.theSet(handles.variables.currentFrame)-1) '.tif']);
    % update the data
    guidata(handles.output, handles);
    
    % Check to see if there are any objects in this frame
    
    % ... if yes
    if handles.variables.objectsInCurrentFrame > 0
    
    
        % plot the next image
        hold on

        image(handles.variables.theImg)
        colormap(gray(128))

        scatter(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base', 'firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,1),handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,2),'.r')

        axis([1 512 1 256])
        axis ij
        axis off

        hold off
    
    % ...if not
    else
    
        while 1
        
            handles.variables.currentObject = 1;
            handles.variables.currentFrame  = handles.variables.currentFrame + 1;
        
            % get the new number of objects
            handles.variables.objectsInCurrentFrame = length(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1});
            % update the picture text
            set(handles.text2, 'String', ['Frame: ' int2str(handles.variables.currentFrame) '/' int2str(length(handles.variables.theSet))]);
            % load new image
            handles.variables.theImg = imread([handles.variables.folder filesep 'Paws' filesep 'paws' int2str(handles.variables.theSet(handles.variables.currentFrame)-1) '.tif']);
            % update the data
            guidata(handles.output, handles);
        
            if handles.variables.objectsInCurrentFrame > 0
                break
            end
        
        end
        
        % plot the next image
        hold on

        image(handles.variables.theImg)
        colormap(gray(128))

        scatter(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base', 'firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,1),handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,2),'.r')

        axis([1 512 1 256])
        axis ij
        axis off

        hold off
        
    end
end


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

set(hObject, 'String', {'Left front paw', 'Right front paw', 'Left hind paw', 'Right hind paw', 'Tail', 'Nothing'});


% --- Executes on button press in backtrack.
function backtrack_Callback(hObject, eventdata, handles)
% hObject    handle to backtrack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% update current values
handles.variables.currentObject = handles.variables.currentObject - 1;
if handles.variables.currentObject == 0
    handles.variables.currentFrame  = handles.variables.currentFrame - 1;
    
    set(handles.text2, 'String', ['Frame: ' int2str(handles.variables.currentFrame) '/' int2str(length(handles.variables.theSet))]);
    
    handles.variables.theImg = imread([handles.variables.folder filesep 'Paws' filesep 'paws' int2str(handles.variables.theSet(handles.variables.currentFrame)-1) '.tif']);
    
    handles.variables.objectsInCurrentFrame = length(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1});
    
    handles.variables.currentObject = handles.variables.objectsInCurrentFrame;
end

% update the data
guidata(handles.output, handles);

% update the image
hold on

image(handles.variables.theImg)
colormap(gray(128))

scatter(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,1),handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,2),'.r')

axis([1 512 1 256])
axis ij
axis off

hold off


% --- Executes on button press in push_tail.
function push_tail_Callback(hObject, eventdata, handles)
% hObject    handle to push_tail (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
cla;

% store value at appropriate place
handles.variables.output{handles.variables.currentFrame}(handles.variables.currentObject) = 5;

% update current values
handles.variables.currentObject = handles.variables.currentObject + 1;
guidata(hObject,handles);

if handles.variables.currentObject > handles.variables.objectsInCurrentFrame
    handles.variables.currentObject = 1;
    handles.variables.currentFrame  = handles.variables.currentFrame + 1;
    
end

if handles.variables.currentFrame > length(handles.variables.theSet)
    % update the data
    guidata(handles.output,handles);
    % save the data
    assignin('base','trainingOutput',handles.variables.output)
    % exit GUI
    delete(handles.figure1)
else
    % get the new number of objects
    handles.variables.objectsInCurrentFrame = length(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1});
    % update the picture text
    set(handles.text2, 'String', ['Frame: ' int2str(handles.variables.currentFrame) '/' int2str(length(handles.variables.theSet))]);
    % load new image
    handles.variables.theImg = imread([handles.variables.folder filesep 'Paws' filesep 'paws' int2str(handles.variables.theSet(handles.variables.currentFrame)-1) '.tif']);
    % update the data
    guidata(handles.output, handles);
    
    % Check to see if there are any objects in this frame
    
    % ... if yes
    if handles.variables.objectsInCurrentFrame > 0
    
    
        % plot the next image
        hold on

        image(handles.variables.theImg)
        colormap(gray(128))

        scatter(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base', 'firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,1),handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,2),'.r')

        axis([1 512 1 256])
        axis ij
        axis off

        hold off
    
    % ...if not
    else
    
        while 1
        
            handles.variables.currentObject = 1;
            handles.variables.currentFrame  = handles.variables.currentFrame + 1;
        
            % get the new number of objects
            handles.variables.objectsInCurrentFrame = length(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1});
            % update the picture text
            set(handles.text2, 'String', ['Frame: ' int2str(handles.variables.currentFrame) '/' int2str(length(handles.variables.theSet))]);
            % load new image
            handles.variables.theImg = imread([handles.variables.folder filesep 'Paws' filesep 'paws' int2str(handles.variables.theSet(handles.variables.currentFrame)-1) '.tif']);
            % update the data
            guidata(handles.output, handles);
        
            if handles.variables.objectsInCurrentFrame > 0
                break
            end
        
        end
        
        % plot the next image
        hold on

        image(handles.variables.theImg)
        colormap(gray(128))

        scatter(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base', 'firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,1),handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,2),'.r')

        axis([1 512 1 256])
        axis ij
        axis off

        hold off
        
    end
end

% --- Executes on button press in push_hindleft.
function push_hindleft_Callback(hObject, eventdata, handles)
% hObject    handle to push_hindleft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
cla;

% store value at appropriate place
handles.variables.output{handles.variables.currentFrame}(handles.variables.currentObject) = 3;

% update current values
handles.variables.currentObject = handles.variables.currentObject + 1;
guidata(hObject,handles);

if handles.variables.currentObject > handles.variables.objectsInCurrentFrame
    handles.variables.currentObject = 1;
    handles.variables.currentFrame  = handles.variables.currentFrame + 1;
    
end

if handles.variables.currentFrame > length(handles.variables.theSet)
    % update the data
    guidata(handles.output,handles);
    % save the data
    assignin('base','trainingOutput',handles.variables.output)
    % exit GUI
    delete(handles.figure1)
else
    % get the new number of objects
    handles.variables.objectsInCurrentFrame = length(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1});
    % update the picture text
    set(handles.text2, 'String', ['Frame: ' int2str(handles.variables.currentFrame) '/' int2str(length(handles.variables.theSet))]);
    % load new image
    handles.variables.theImg = imread([handles.variables.folder filesep 'Paws' filesep 'paws' int2str(handles.variables.theSet(handles.variables.currentFrame)-1) '.tif']);
    % update the data
    guidata(handles.output, handles);
    
    % Check to see if there are any objects in this frame
    
    % ... if yes
    if handles.variables.objectsInCurrentFrame > 0
    
    
        % plot the next image
        hold on

        image(handles.variables.theImg)
        colormap(gray(128))

        scatter(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base', 'firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,1),handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,2),'.r')

        axis([1 512 1 256])
        axis ij
        axis off

        hold off
    
    % ...if not
    else
    
        while 1
        
            handles.variables.currentObject = 1;
            handles.variables.currentFrame  = handles.variables.currentFrame + 1;
        
            % get the new number of objects
            handles.variables.objectsInCurrentFrame = length(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1});
            % update the picture text
            set(handles.text2, 'String', ['Frame: ' int2str(handles.variables.currentFrame) '/' int2str(length(handles.variables.theSet))]);
            % load new image
            handles.variables.theImg = imread([handles.variables.folder filesep 'Paws' filesep 'paws' int2str(handles.variables.theSet(handles.variables.currentFrame)-1) '.tif']);
            % update the data
            guidata(handles.output, handles);
        
            if handles.variables.objectsInCurrentFrame > 0
                break
            end
        
        end
        
        % plot the next image
        hold on

        image(handles.variables.theImg)
        colormap(gray(128))

        scatter(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base', 'firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,1),handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,2),'.r')

        axis([1 512 1 256])
        axis ij
        axis off

        hold off
        
    end
end


% --- Executes on button press in push_hindright.
function push_hindright_Callback(hObject, eventdata, handles)
% hObject    handle to push_hindright (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
cla;

popup_sel_index = get(handles.popupmenu1, 'Value');
        
% store value at appropriate place
handles.variables.output{handles.variables.currentFrame}(handles.variables.currentObject) = 4;

% update current values
handles.variables.currentObject = handles.variables.currentObject + 1;
guidata(hObject,handles);

if handles.variables.currentObject > handles.variables.objectsInCurrentFrame
    handles.variables.currentObject = 1;
    handles.variables.currentFrame  = handles.variables.currentFrame + 1;
    
end

if handles.variables.currentFrame > length(handles.variables.theSet)
    % update the data
    guidata(handles.output,handles);
    % save the data
    assignin('base','trainingOutput',handles.variables.output)
    % exit GUI
    delete(handles.figure1)
else
    % get the new number of objects
    handles.variables.objectsInCurrentFrame = length(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1});
    % update the picture text
    set(handles.text2, 'String', ['Frame: ' int2str(handles.variables.currentFrame) '/' int2str(length(handles.variables.theSet))]);
    % load new image
    handles.variables.theImg = imread([handles.variables.folder filesep 'Paws' filesep 'paws' int2str(handles.variables.theSet(handles.variables.currentFrame)-1) '.tif']);
    % update the data
    guidata(handles.output, handles);
    
    % Check to see if there are any objects in this frame
    
    % ... if yes
    if handles.variables.objectsInCurrentFrame > 0
    
    
        % plot the next image
        hold on

        image(handles.variables.theImg)
        colormap(gray(128))

        scatter(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base', 'firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,1),handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,2),'.r')

        axis([1 512 1 256])
        axis ij
        axis off

        hold off
    
    % ...if not
    else
    
        while 1
        
            handles.variables.currentObject = 1;
            handles.variables.currentFrame  = handles.variables.currentFrame + 1;
        
            % get the new number of objects
            handles.variables.objectsInCurrentFrame = length(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1});
            % update the picture text
            set(handles.text2, 'String', ['Frame: ' int2str(handles.variables.currentFrame) '/' int2str(length(handles.variables.theSet))]);
            % load new image
            handles.variables.theImg = imread([handles.variables.folder filesep 'Paws' filesep 'paws' int2str(handles.variables.theSet(handles.variables.currentFrame)-1) '.tif']);
            % update the data
            guidata(handles.output, handles);
        
            if handles.variables.objectsInCurrentFrame > 0
                break
            end
        
        end
        
        % plot the next image
        hold on

        image(handles.variables.theImg)
        colormap(gray(128))

        scatter(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base', 'firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,1),handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,2),'.r')

        axis([1 512 1 256])
        axis ij
        axis off

        hold off
        
    end
end


% --- Executes on button press in push_nothing.
function push_nothing_Callback(hObject, eventdata, handles)
% hObject    handle to push_nothing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes1);
cla;
        
% store value at appropriate place
handles.variables.output{handles.variables.currentFrame}(handles.variables.currentObject) = 6;


% update current values
handles.variables.currentObject = handles.variables.currentObject + 1;
if handles.variables.currentObject > handles.variables.objectsInCurrentFrame
    handles.variables.currentObject = 1;
    handles.variables.currentFrame  = handles.variables.currentFrame + 1;
end

if handles.variables.currentFrame > length(handles.variables.theSet)
    % update the data
    guidata(handles.output,handles);
    % save the data
    assignin('base','trainingOutput',handles.variables.output)
    % exit GUI
    delete(handles.figure1)
else
    % get the new number of objects
    handles.variables.objectsInCurrentFrame = length(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1});
    % update the picture text
    set(handles.text2, 'String', ['Frame: ' int2str(handles.variables.currentFrame) '/' int2str(length(handles.variables.theSet))]);
    % load new image
    handles.variables.theImg = imread([handles.variables.folder filesep 'Paws' filesep 'paws' int2str(handles.variables.theSet(handles.variables.currentFrame)-1) '.tif']);
    % update the data
    guidata(handles.output, handles);
    
    % Check to see if there are any objects in this frame
    
    % ... if yes
    if handles.variables.objectsInCurrentFrame > 0
    
    
        % plot the next image
        hold on

        image(handles.variables.theImg)
        colormap(gray(128))

        scatter(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base', 'firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,1),handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,2),'.r')

        axis([1 512 1 256])
        axis ij
        axis off

        hold off
    
    % ...if not
    else
    
        while 1
        
            handles.variables.currentObject = 1;
            handles.variables.currentFrame  = handles.variables.currentFrame + 1;
        
            % get the new number of objects
            handles.variables.objectsInCurrentFrame = length(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1});
            % update the picture text
            set(handles.text2, 'String', ['Frame: ' int2str(handles.variables.currentFrame) '/' int2str(length(handles.variables.theSet))]);
            % load new image
            handles.variables.theImg = imread([handles.variables.folder filesep 'Paws' filesep 'paws' int2str(handles.variables.theSet(handles.variables.currentFrame)-1) '.tif']);
            % update the data
            guidata(handles.output, handles);
        
            if handles.variables.objectsInCurrentFrame > 0
                break
            end
        
        end
        
        % plot the next image
        hold on

        image(handles.variables.theImg)
        colormap(gray(128))

        scatter(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base', 'firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,1),handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,2),'.r')

        axis([1 512 1 256])
        axis ij
        axis off

        hold off
        
    end
end





% --- Executes on button press in push_frontleft.
function push_frontleft_Callback(hObject, eventdata, handles)
% hObject    handle to push_frontleft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes1);
cla;


% store value at appropriate place
handles.variables.output{handles.variables.currentFrame}(handles.variables.currentObject) = 1;

% update current values
handles.variables.currentObject = handles.variables.currentObject + 1;
if handles.variables.currentObject > handles.variables.objectsInCurrentFrame
    handles.variables.currentObject = 1;
    handles.variables.currentFrame  = handles.variables.currentFrame + 1;
end

if handles.variables.currentFrame > length(handles.variables.theSet)
    % update the data
    guidata(handles.output,handles);
    % save the data
    assignin('base','trainingOutput',handles.variables.output)
    % exit GUI
    delete(handles.figure1)
else
    % get the new number of objects
    handles.variables.objectsInCurrentFrame = length(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1});
    % update the picture text
    set(handles.text2, 'String', ['Frame: ' int2str(handles.variables.currentFrame) '/' int2str(length(handles.variables.theSet))]);
    % load new image
    handles.variables.theImg = imread([handles.variables.folder filesep 'Paws' filesep 'paws' int2str(handles.variables.theSet(handles.variables.currentFrame)-1) '.tif']);
    % update the data
    guidata(handles.output, handles);
    
    % Check to see if there are any objects in this frame
    
    % ... if yes
    if handles.variables.objectsInCurrentFrame > 0
    
    
        % plot the next image
        hold on

        image(handles.variables.theImg)
        colormap(gray(128))

        scatter(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base', 'firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,1),handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,2),'.r')

        axis([1 512 1 256])
        axis ij
        axis off

        hold off
    
    % ...if not
    else
    
        while 1
        
            handles.variables.currentObject = 1;
            handles.variables.currentFrame  = handles.variables.currentFrame + 1;
        
            % get the new number of objects
            handles.variables.objectsInCurrentFrame = length(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1});
            % update the picture text
            set(handles.text2, 'String', ['Frame: ' int2str(handles.variables.currentFrame) '/' int2str(length(handles.variables.theSet))]);
            % load new image
            handles.variables.theImg = imread([handles.variables.folder filesep 'Paws' filesep 'paws' int2str(handles.variables.theSet(handles.variables.currentFrame)-1) '.tif']);
            % update the data
            guidata(handles.output, handles);
        
            if handles.variables.objectsInCurrentFrame > 0
                break
            end
        
        end
        
        % plot the next image
        hold on

        image(handles.variables.theImg)
        colormap(gray(128))

        scatter(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base', 'firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,1),handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,2),'.r')

        axis([1 512 1 256])
        axis ij
        axis off

        hold off
        
    end
end



% --- Executes on button press in push_frontright.
function push_frontright_Callback(hObject, eventdata, handles)
% hObject    handle to push_frontright (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
cla;

handles.variables.output{handles.variables.currentFrame}(handles.variables.currentObject) = 2;
        
% update current values
handles.variables.currentObject = handles.variables.currentObject + 1;
if handles.variables.currentObject > handles.variables.objectsInCurrentFrame
    handles.variables.currentObject = 1;
    handles.variables.currentFrame  = handles.variables.currentFrame + 1;
end

if handles.variables.currentFrame > length(handles.variables.theSet)
    % update the data
    guidata(handles.output,handles);
    % save the data
    assignin('base','trainingOutput',handles.variables.output)
    % exit GUI
    delete(handles.figure1)
else
    % get the new number of objects
    handles.variables.objectsInCurrentFrame = length(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1});
    % update the picture text
    set(handles.text2, 'String', ['Frame: ' int2str(handles.variables.currentFrame) '/' int2str(length(handles.variables.theSet))]);
    % load new image
    handles.variables.theImg = imread([handles.variables.folder filesep 'Paws' filesep 'paws' int2str(handles.variables.theSet(handles.variables.currentFrame)-1) '.tif']);
    % update the data
    guidata(handles.output, handles);
    
    % Check to see if there are any objects in this frame
    
    % ... if yes
    if handles.variables.objectsInCurrentFrame > 0
    
    
        % plot the next image
        hold on

        image(handles.variables.theImg)
        colormap(gray(128))

        scatter(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base', 'firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,1),handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,2),'.r')

        axis([1 512 1 256])
        axis ij
        axis off

        hold off
    
    % ...if not
    else
    
        while 1
        
            handles.variables.currentObject = 1;
            handles.variables.currentFrame  = handles.variables.currentFrame + 1;
        
            % get the new number of objects
            handles.variables.objectsInCurrentFrame = length(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1});
            % update the picture text
            set(handles.text2, 'String', ['Frame: ' int2str(handles.variables.currentFrame) '/' int2str(length(handles.variables.theSet))]);
            % load new image
            handles.variables.theImg = imread([handles.variables.folder filesep 'Paws' filesep 'paws' int2str(handles.variables.theSet(handles.variables.currentFrame)-1) '.tif']);
            % update the data
            guidata(handles.output, handles);
        
            if handles.variables.objectsInCurrentFrame > 0
                break
            end
        
        end
        
        % plot the next image
        hold on

        image(handles.variables.theImg)
        colormap(gray(128))

        scatter(handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base', 'firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,1),handles.variables.objects{handles.variables.theSet(handles.variables.currentFrame) - evalin('base','firstFrame') + 1}{handles.variables.currentObject}.PixelList(:,2),'.r')

        axis([1 512 1 256])
        axis ij
        axis off

        hold off
        
    end
end


