%% Code by J.R. De Gruijl, Revisions by J.R. De Gruijl and T.M. Hoogland 2013

function varargout = exclude_frames_GUI(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @exclude_frames_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @exclude_frames_GUI_OutputFcn, ...
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

% --- Executes just before exclude_frames_GUI is made visible.
function exclude_frames_GUI_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

motionfile = dir('*motion*.mat');
load(motionfile.name);
load('body_axis.mat')
load('fits_and_objects.mat')
load('headloc.mat')
load('bufferReady.mat')

cd('preprocessed');
files_proc = dir('*.tif');
cd ..

handles.vars.files_proc  = files_proc(2:end);
handles.vars.files_orig  = dir('*.tif');
handles.vars.mode        = 1; % 1=original ; 2=preprocessed ; 3=thresholded
handles.vars.angles      = bodyangle;
handles.vars.tangles     = tailangle;
handles.vars.iffy_frames = estimate_borked_frame_trigpoints(bodyangle);
handles.vars.move_frames = get_locomotion_frames(bufferReady-8,motion .* procdata(:,1));
handles.vars.now         = 1;
handles.vars.excl_frames = [];
handles.vars.head        = head_coords;
handles.vars.bufferready = bufferReady-8;
handles.vars.tailfits    = tailfits;
handles.vars.bodyfits    = bodyfits;

img_n = length(handles.vars.files_orig);
handles.vars.img_n       = img_n;

% slope = -tand(handles.vars.angles(handles.vars.now));

%t     = -511:0;
%body  = slope * t + handles.vars.head(2);

%delta = -tand(handles.vars.tangles(handles.vars.now));
%tail  = delta * t + handles.vars.head(2);

t    = 1:512;
body = handles.vars.bodyfits(handles.vars.now,1) * t + handles.vars.bodyfits(handles.vars.now,2);
tail = handles.vars.tailfits(handles.vars.now,1) * t + handles.vars.tailfits(handles.vars.now,2); % fitted tail line (absolute, not relative)

if strcmp(get(hObject,'Visible'),'off')
    %try
    
        axes(handles.axes2);
        %hold on
        plot(bodyangle,'Color',[0.9 0.9 0.9],'LineWidth',0.5)
        hold on
        plot([1 1], [(min(bodyangle)-1) (max(bodyangle)+1)],'Color', [0.25 0.25 0.25]);
        
        % fix for common error in which vector is wrongly oriented
        if(size(bodyangle,1)>size(handles.vars.move_frames,1))
            bodyangle=bodyangle';
        end
        plot(bodyangle .* sign(handles.vars.move_frames),'k','LineWidth',0.5)
        if ~isempty(handles.vars.iffy_frames)
        scatter(handles.vars.iffy_frames(:,1),handles.vars.angles(handles.vars.iffy_frames(:,1)),'*r');
        end
        hold off
        %hold off
        axis([1 img_n (min(bodyangle)-1) (max(bodyangle)+1)])
        axis off
        
        axes(handles.axes1);
        %cla;
        img = double(imread(handles.vars.files_orig(1).name));
        dims = size(img);
        if isnan(handles.vars.move_frames(handles.vars.now))
            img = round(0.5 .* img + 32);
        end
        %handles.vars.img    = img;
        %img = double(img) ./ double(max(max(img)));
        image(img);
        
        hold on
        plot(body,'y-','LineWidth',0.5,'LineSmoothing','on')
        plot(tail,'r--','LineWidth',0.5,'LineSmoothing','on')
        %plot(t + handles.vars.head(1),tail,'--r','LineWidth',0.5)
        hold off
        colormap gray
        axis([1 dims(2) 1 dims(1)])
        axis ij
        axis off
    %catch
        %handles.vars.img = [];
    %end
end

set(handles.slider2,'SliderStep',[(1 / img_n) (10 / img_n)]);
set(handles.frameDisplayText,'String',['Current frame: ' int2str(1) '/' int2str(img_n)])

guidata(hObject, handles);

function varargout = exclude_frames_GUI_OutputFcn(hObject, eventdata, handles)

varargout{1} = handles.output;

% --- Executes on button press in thresholdedButton.
function thresholdedButton_Callback(hObject, eventdata, handles)

handles.vars.mode = 3;

% slope = -tand(handles.vars.angles(handles.vars.now));
% t     = -511:0;
% body  = slope * t + handles.vars.head(2);
% tail  = handles.vars.tailfits(handles.vars.now,1) * t + handles.vars.tailfits(handles.vars.now,2);

t    = 1:512;
body = handles.vars.bodyfits(handles.vars.now,1) * t + handles.vars.bodyfits(handles.vars.now,2);
tail = handles.vars.tailfits(handles.vars.now,1) * t + handles.vars.tailfits(handles.vars.now,2);

% plot the image again
axes(handles.axes1);
cla;
img = double(imread([cd filesep 'preprocessed' filesep handles.vars.files_proc(handles.vars.now).name]));
dims = size(img);
img(img < mean(max(img))) = 0;
img(img > 0)              = 255;
if isnan(handles.vars.move_frames(handles.vars.now))
    img = round(0.5 .* img + 32);
end
image(img)
hold on
plot(body,'y-','LineWidth',0.5,'LineSmoothing','on')
plot(tail,'r--','LineWidth',0.5,'LineSmoothing','on')
hold off
axis([1 dims(2) 1 dims(1)])
axis ij
axis off
guidata(hObject, handles);

guidata(hObject, handles);

% --- Executes on button press in originalButton.
function originalButton_Callback(hObject, eventdata, handles)

handles.vars.mode = 1;

t    = 1:512;
body = handles.vars.bodyfits(handles.vars.now,1) * t + handles.vars.bodyfits(handles.vars.now,2);
tail = handles.vars.tailfits(handles.vars.now,1) * t + handles.vars.tailfits(handles.vars.now,2);

% plot the image again
axes(handles.axes1);
cla;
img = double(imread(handles.vars.files_orig(handles.vars.now).name));
dims = size(img);
if isnan(handles.vars.move_frames(handles.vars.now))
    img = round(0.5 .* img + 32);
end
image(img)
hold on
plot(body,'y-','LineWidth',0.5,'LineSmoothing','on')
plot(tail,'r--','LineWidth',0.5,'LineSmoothing','on')
hold off
axis([1 dims(2) 1 dims(1)])
axis ij
axis off
guidata(hObject, handles);
guidata(hObject, handles);

% --- Executes on button press in exitButton.
function exitButton_Callback(hObject, eventdata, handles)

final_frames = handles.vars.move_frames;
save('exclude_frames.mat','final_frames');

folderstate                = get_folder_state(cd);
h                          = trackGaitMain;
the_data                   = guidata(h);
the_data.vars.folderState  = folderstate;
set(the_data.framesExcludedDisplay,'String',['Frames excluded: ' folderstate.exclude_frames]);
guidata(h,the_data)
drawnow();
delete(handles.figure1)


% --- Executes on button press in preprocessedButton.
function preprocessedButton_Callback(hObject, eventdata, handles)

handles.vars.mode = 2;

% slope = -tand(handles.vars.angles(handles.vars.now));
% t     = -511:0;
% body  = slope * t + handles.vars.head(2);
% tail  = handles.vars.tailfits(handles.vars.now,1) * t + handles.vars.tailfits(handles.vars.now,2);
t    = 1:512;
body = handles.vars.bodyfits(handles.vars.now,1) * t + handles.vars.bodyfits(handles.vars.now,2);
tail = handles.vars.tailfits(handles.vars.now,1) * t + handles.vars.tailfits(handles.vars.now,2);

% plot the image again
axes(handles.axes1);
cla;
img = double(imread([cd filesep 'preprocessed' filesep handles.vars.files_proc(handles.vars.now).name]));
dims = size(img);
if isnan(handles.vars.move_frames(handles.vars.now))
    img = round(0.5 .* img + 32);
end
image(img)
hold on
plot(body,'y-','LineWidth',0.5,'LineSmoothing','on')
plot(tail,'r--','LineWidth',0.5,'LineSmoothing','on')
hold off
axis([1 dims(2) 1 dims(1)])
axis ij
axis off
guidata(hObject, handles);


% --- Executes on button press in excludeCurrent.
function excludeCurrent_Callback(hObject, eventdata, handles)

handles.vars.move_frames(handles.vars.now) = NaN;

axes(handles.axes2);
        %hold on
plot(handles.vars.angles,'Color',[0.9 0.9 0.9],'LineWidth',0.5)
hold on
plot([handles.vars.now handles.vars.now], [(min(handles.vars.angles)-1) (max(handles.vars.angles)+1)],'Color', [0.25 0.25 0.25]);

% fix for incorrect orientation vectors
if(size(handles.vars.angles,1)>size(handles.vars.move_frames,1))
    tmp=handles.vars.angles;
    tmp=tmp';
    handles.vars.angles=tmp;
    guidata(hObject,handles);
end
plot(handles.vars.angles .* sign(handles.vars.move_frames),'k','LineWidth',0.5)
if ~isempty(handles.vars.iffy_frames)
scatter(handles.vars.iffy_frames(:,1),handles.vars.angles(handles.vars.iffy_frames(:,1)),'*r');
end
hold off
axis([1 handles.vars.img_n (min(handles.vars.angles)-1) (max(handles.vars.angles)+1)])
axis off

% slope = -tand(handles.vars.angles(handles.vars.now));
% t     = -511:0;
% body  = slope * t + handles.vars.head(2);
% tail  = handles.vars.tailfits(handles.vars.now,1) * t + handles.vars.tailfits(handles.vars.now,2);

t    = 1:512;
body = handles.vars.bodyfits(handles.vars.now,1) * t + handles.vars.bodyfits(handles.vars.now,2);
tail = handles.vars.tailfits(handles.vars.now,1) * t + handles.vars.tailfits(handles.vars.now,2);

axes(handles.axes1);
cla;
if (handles.vars.mode == 1)
    img = double(imread(handles.vars.files_orig(handles.vars.now).name));
elseif (handles.vars.mode == 2)
    img = double(imread([cd filesep 'preprocessed' filesep handles.vars.files_proc(handles.vars.now).name]));
else
    img = double(imread([cd filesep 'preprocessed' filesep handles.vars.files_proc(handles.vars.now).name]));
    
    img(img < mean(max(img))) = 0;
    img(img > 0)              = 255;
end
dims = size(img);
if isnan(handles.vars.move_frames(handles.vars.now))
    img = round(0.5 .* img + 32);
end
image(img)
hold on
plot(body,'y-','LineWidth',0.5,'LineSmoothing','on')
plot(tail,'r--','LineWidth',0.5,'LineSmoothing','on')
hold off
axis([1 dims(2) 1 dims(1)])
axis ij
axis off
guidata(hObject, handles);

% refocus on slider
uicontrol(handles.slider2);

function range_begin_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function range_begin_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function range_end_Callback(hObject, eventdata, handles)

function range_end_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function excludeRange_Callback(hObject, eventdata, handles)

try
    pos1 = str2double(get(handles.range_begin,'String'));
    if pos1 > handles.vars.img_n
        pos1 = handles.vars.img_n;
        set(handles.range_begin,'String',int2str(handles.vars.img_n));
    end
    if pos1 < 1
        pos1 = 1;
        set(handles.range_begin,'String','1');
    end
catch
    pos1 = handles.vars.now;
end

try
    pos2 = str2double(get(handles.range_end,'String'));
    if pos2 > handles.vars.img_n
        pos2 = handles.vars.img_n;
        set(handles.range_end,'String',int2str(handles.vars.img_n));
    end
    if pos2 < 1
        pos2 = 1;
        set(handles.range_end,'String','1');
    end
catch
    pos2 = handles.vars.now;
end

try
    if pos2 < pos1
        pos2 = pos1;
    end
catch
end

% Set frames in defined range to NaN *exclude them*
handles.vars.move_frames(pos1:pos2) = NaN;

axes(handles.axes2);
plot(handles.vars.angles,'Color',[0.9 0.9 0.9],'LineWidth',0.5)
hold on
plot([handles.vars.now handles.vars.now], [(min(handles.vars.angles)-1) (max(handles.vars.angles)+1)],'Color', [0.25 0.25 0.25]);

% fix for incorrect orientation vectors
if(size(handles.vars.angles,1)>size(handles.vars.move_frames,1))
    tmp=handles.vars.angles;
    tmp=tmp';
    handles.vars.angles=tmp;
    guidata(hObject,handles);
end

plot(handles.vars.angles .* sign(handles.vars.move_frames),'k','LineWidth',0.5)
if ~isempty(handles.vars.iffy_frames)
scatter(handles.vars.iffy_frames(:,1),handles.vars.angles(handles.vars.iffy_frames(:,1)),'*r');
end
hold off
axis([1 handles.vars.img_n (min(handles.vars.angles)-1) (max(handles.vars.angles)+1)])
axis off

% slope = -tand(handles.vars.angles(handles.vars.now));
% t     = -511:0;
% body  = slope * t + handles.vars.head(2);
% tail  = handles.vars.tailfits(handles.vars.now,1) * t + handles.vars.tailfits(handles.vars.now,2);
t    = 1:512;
body = handles.vars.bodyfits(handles.vars.now,1) * t + handles.vars.bodyfits(handles.vars.now,2);
tail = handles.vars.tailfits(handles.vars.now,1) * t + handles.vars.tailfits(handles.vars.now,2);
axes(handles.axes1);
cla;
if (handles.vars.mode == 1)
    img = double(imread(handles.vars.files_orig(handles.vars.now).name));
elseif (handles.vars.mode == 2)
    img = double(imread([cd filesep 'preprocessed' filesep handles.vars.files_proc(handles.vars.now).name]));
else
    img = double(imread([cd filesep 'preprocessed' filesep handles.vars.files_proc(handles.vars.now).name]));
    
    img(img < mean(max(img))) = 0;
    img(img > 0)              = 255;
end
dims = size(img);
if isnan(handles.vars.move_frames(handles.vars.now))
    img = round(0.5 .* img + 32);
end
image(img)
hold on
plot(body,'y-','LineWidth',0.5,'LineSmoothing','on')
plot(tail,'r--','LineWidth',0.5,'LineSmoothing','on')
hold off
axis([1 dims(2) 1 dims(1)])
axis ij
axis off
guidata(hObject, handles);


% refocus on slider
uicontrol(handles.slider2);

% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)

val = get(hObject,'Value');
pos = round(val * handles.vars.img_n);
handles.vars.now = pos;
set(handles.frameDisplayText,'String',['Current frame: ' int2str(pos) '/' int2str(handles.vars.img_n)]);

axes(handles.axes2);
cla;
plot(handles.vars.angles,'Color',[0.9 0.9 0.9],'LineWidth',0.5)
hold on
plot([pos pos], [(min(handles.vars.angles)-1) (max(handles.vars.angles)+1)],'Color', [0.25 0.25 0.25]);

% fix for incorrect orientation vectors
if(size(handles.vars.angles,1)>size(handles.vars.move_frames,1))
    tmp=handles.vars.angles;
    tmp=tmp';
    handles.vars.angles=tmp;
    guidata(hObject,handles);
end

if(pos<1) % Ensure to keep frame 1 when setting slider < 1
    handles.vars.now = 1;
    guidata(hObject,handles); 
    pos=1;
end
    
    plot(handles.vars.angles .* sign(handles.vars.move_frames),'k','LineWidth',0.5)

    if ~isempty(handles.vars.iffy_frames)
    scatter(handles.vars.iffy_frames(:,1),handles.vars.angles(handles.vars.iffy_frames(:,1)),'*r');
    end
    hold off
    axis([1 handles.vars.img_n (min(handles.vars.angles)-1) (max(handles.vars.angles)+1)])
    axis off
    
% slope = -tand(handles.vars.angles(handles.vars.now));
% t     = -511:0;
% body  = slope * t + handles.vars.head(2);
% tail  = handles.vars.tailfits(handles.vars.now,1) * t + handles.vars.tailfits(handles.vars.now,2);
t    = 1:512;
body = handles.vars.bodyfits(handles.vars.now,1) * t + handles.vars.bodyfits(handles.vars.now,2);
tail = handles.vars.tailfits(handles.vars.now,1) * t + handles.vars.tailfits(handles.vars.now,2);
axes(handles.axes1);
cla;
if (handles.vars.mode == 1)
    img = double(imread(handles.vars.files_orig(pos).name));
elseif (handles.vars.mode == 2)
    img = double(imread([cd filesep 'preprocessed' filesep handles.vars.files_proc(pos).name]));
else
    img = double(imread([cd filesep 'preprocessed' filesep handles.vars.files_proc(pos).name]));
    
    img(img < mean(max(img))) = 0;
    img(img > 0)              = 255;
end
if isnan(handles.vars.move_frames(handles.vars.now))
    img = round(0.5 .* img + 32);
end
image(img);
hold on
plot(body,'y-','LineWidth',0.5,'LineSmoothing','on')
plot(tail,'r--','LineWidth',0.5,'LineSmoothing','on')
hold off
colormap gray
axis off
drawnow();
guidata(hObject, handles);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in includeCurrent.
function includeCurrent_Callback(hObject, eventdata, handles)

handles.vars.move_frames(handles.vars.now) = handles.vars.bufferready(handles.vars.now);
%handles.vars.move_frames = get_locomotion_frames(bufferReady-8,motion .* procdata(:,1));
move_frames_buffer = get_locomotion_frames(bufferReady-8,motion .* procdata(:,1));

axes(handles.axes2);
        %hold on
plot(handles.vars.angles,'Color',[0.9 0.9 0.9],'LineWidth',0.5)
hold on
plot([handles.vars.now handles.vars.now], [(min(handles.vars.angles)-1) (max(handles.vars.angles)+1)],'Color', [0.25 0.25 0.25]);

% fix for incorrect orientation vectors
if(size(handles.vars.angles,1)>size(handles.vars.move_frames,1))
    tmp=handles.vars.angles;
    tmp=tmp';
    handles.vars.angles=tmp;
    guidata(hObject,handles);
end
plot(handles.vars.angles .* sign(handles.vars.move_frames),'k','LineWidth',0.5)
if ~isempty(handles.vars.iffy_frames)
scatter(handles.vars.iffy_frames(:,1),handles.vars.angles(handles.vars.iffy_frames(:,1)),'*r');
end
hold off
axis([1 handles.vars.img_n (min(handles.vars.angles)-1) (max(handles.vars.angles)+1)])
axis off

% slope = -tand(handles.vars.angles(handles.vars.now));
% t     = -511:0;
% body  = slope * t + handles.vars.head(2);
% tail  = handles.vars.tailfits(handles.vars.now,1) * t + handles.vars.tailfits(handles.vars.now,2);
t    = 1:512;
body = handles.vars.bodyfits(handles.vars.now,1) * t + handles.vars.bodyfits(handles.vars.now,2);
tail = handles.vars.tailfits(handles.vars.now,1) * t + handles.vars.tailfits(handles.vars.now,2);
axes(handles.axes1);
cla;
if (handles.vars.mode == 1)
    img = double(imread(handles.vars.files_orig(handles.vars.now).name));
elseif (handles.vars.mode == 2)
    img = double(imread([cd filesep 'preprocessed' filesep handles.vars.files_proc(handles.vars.now).name]));
else
    img = double(imread([cd filesep 'preprocessed' filesep handles.vars.files_proc(handles.vars.now).name]));
    
    img(img < mean(max(img))) = 0;
    img(img > 0)              = 255;
end
dims = size(img);
if isnan(handles.vars.move_frames(handles.vars.now))
    img = round(0.5 .* img + 32);
end
image(img)
hold on
plot(body,'y-','LineWidth',0.5,'LineSmoothing','on')
plot(tail,'r--','LineWidth',0.5,'LineSmoothing','on')
hold off
axis([1 dims(2) 1 dims(1)])
axis ij
axis off
guidata(hObject, handles);


% refocus on slider
uicontrol(handles.slider2);


function jump2frame_Callback(hObject, eventdata, handles)

try
    pos = str2double(get(hObject,'String'));
    if pos > handles.vars.img_n
        pos = handles.vars.img_n;
        set(hObject,'String',int2str(handles.vars.img_n));
    end
    if pos < 1
        pos = 1;
        set(hObject,'String','1');
    end
catch
    pos = handles.vars.now;
end

handles.vars.now = pos;
set(handles.frameDisplayText,'String',['Current frame: ' int2str(pos) '/' int2str(handles.vars.img_n)]);

axes(handles.axes2);
cla;
plot(handles.vars.angles,'Color',[0.9 0.9 0.9],'LineWidth',0.5)
hold on
plot([pos pos], [(min(handles.vars.angles)-1) (max(handles.vars.angles)+1)],'Color', [0.25 0.25 0.25]);
plot(handles.vars.angles .* sign(handles.vars.move_frames),'k','LineWidth',0.5)
if ~isempty(handles.vars.iffy_frames)
scatter(handles.vars.iffy_frames(:,1),handles.vars.angles(handles.vars.iffy_frames(:,1)),'*r');
end
hold off
axis([1 handles.vars.img_n (min(handles.vars.angles)-1) (max(handles.vars.angles)+1)])
axis off

% slope = -tand(handles.vars.angles(handles.vars.now));
% t     = -511:0;
% body  = slope * t + handles.vars.head(2);
% tail  = handles.vars.tailfits(handles.vars.now,1) * t + handles.vars.tailfits(handles.vars.now,2);
t    = 1:512;
body = handles.vars.bodyfits(handles.vars.now,1) * t + handles.vars.bodyfits(handles.vars.now,2);
tail = handles.vars.tailfits(handles.vars.now,1) * t + handles.vars.tailfits(handles.vars.now,2);
axes(handles.axes1);
cla;
if (handles.vars.mode == 1)
    img = double(imread(handles.vars.files_orig(pos).name));
elseif (handles.vars.mode == 2)
    img = double(imread([cd filesep 'preprocessed' filesep handles.vars.files_proc(pos).name]));
else
    img = double(imread([cd filesep 'preprocessed' filesep handles.vars.files_proc(pos).name]));
    
    img(img < mean(max(img))) = 0;
    img(img > 0)              = 255;
end
if isnan(handles.vars.move_frames(handles.vars.now))
    img = round(0.5 .* img + 32);
end
image(img);
hold on
plot(body,'y-','LineWidth',0.5,'LineSmoothing','on')
plot(tail,'r--','LineWidth',0.5,'LineSmoothing','on')
hold off
colormap gray
axis off

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function jump2frame_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in includeRange.
function includeRange_Callback(hObject, eventdata, handles)

try
    pos1 = str2double(get(handles.range_begin,'String'));
    if pos1 > handles.vars.img_n
        pos1 = handles.vars.img_n;
        set(handles.range_begin,'String',int2str(handles.vars.img_n));
    end
    if pos1 < 1
        pos1 = 1;
        set(handles.range_begin,'String','1');
    end
catch
    pos1 = handles.vars.now;
end

try
    pos2 = str2double(get(handles.range_end,'String'));
    if pos2 > handles.vars.img_n
        pos2 = handles.vars.img_n;
        set(handles.range_end,'String',int2str(handles.vars.img_n));
    end
    if pos2 < 1
        pos2 = 1;
        set(handles.range_end,'String','1');
    end
catch
    pos2 = handles.vars.now;
end

try
    if pos2 < pos1
        pos2 = pos1;
    end
catch
end
% End section taking care of boundary conditions

% Here values are included between beginning and end positions
motionfile = dir('*motion*.mat');
handles.vars.move_frames(pos1:pos2) = 1;
guidata(hObject,handles);

clear move_frames;

%plot angle trace 
axes(handles.axes2);
cla;
hold on;
plot(handles.vars.angles,'Color',[0.9 0.9 0.9],'LineWidth',0.5);

hold on;
%line indincating position of slider
plot([handles.vars.now handles.vars.now], [(min(handles.vars.angles)-1) (max(handles.vars.angles)+1)],'Color', [0.25 0.25 0.25]);

% fix for incorrect orientation vectors
if(size(handles.vars.angles,1)>size(handles.vars.move_frames,1))
    tmp=handles.vars.angles;
    tmp=tmp';
    handles.vars.angles=tmp;
    guidata(hObject,handles);
end

plot(handles.vars.angles .* sign(handles.vars.move_frames),'k','LineWidth',0.5)
if ~isempty(handles.vars.iffy_frames)
scatter(handles.vars.iffy_frames(:,1),handles.vars.angles(handles.vars.iffy_frames(:,1)),'*r');
end
hold off
axis([1 handles.vars.img_n (min(handles.vars.angles)-1) (max(handles.vars.angles)+1)])
axis off

t    = 1:512;
body = handles.vars.bodyfits(handles.vars.now,1) * t + handles.vars.bodyfits(handles.vars.now,2);
tail = handles.vars.tailfits(handles.vars.now,1) * t + handles.vars.tailfits(handles.vars.now,2);
axes(handles.axes1);

cla;
if (handles.vars.mode == 1)
    img = double(imread(handles.vars.files_orig(handles.vars.now).name));
elseif (handles.vars.mode == 2)
    img = double(imread([cd filesep 'preprocessed' filesep handles.vars.files_proc(handles.vars.now).name]));
else
    img = double(imread([cd filesep 'preprocessed' filesep handles.vars.files_proc(handles.vars.now).name]));
    
    img(img < mean(max(img))) = 0;
    img(img > 0)              = 255;
end
dims = size(img);
if isnan(handles.vars.move_frames(handles.vars.now))
    img = round(0.5 .* img + 32);
end
image(img)
hold on
plot(body,'w','LineWidth',0.5,'LineSmoothing','on')
plot(tail,'r--','LineWidth',0.5,'LineSmoothing','on')
hold off
axis([1 dims(2) 1 dims(1)])
axis ij
axis off
guidata(hObject, handles);


% refocus on slider
uicontrol(handles.slider2);
