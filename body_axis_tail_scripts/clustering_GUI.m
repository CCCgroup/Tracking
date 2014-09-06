function varargout = clustering_GUI(varargin)
% CLUSTERING_GUI M-file for clustering_GUI.fig
%      CLUSTERING_GUI, by itself, creates a new CLUSTERING_GUI or raises the existing
%      singleton*.
%
%      H = CLUSTERING_GUI returns the handle to a new CLUSTERING_GUI or the handle to
%      the existing singleton*.
%
%      CLUSTERING_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CLUSTERING_GUI.M with the given input arguments.
%
%      CLUSTERING_GUI('Property','Value',...) creates a new CLUSTERING_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before clustering_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to clustering_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help clustering_GUI

% Last Modified by GUIDE v2.5 06-Mar-2013 15:59:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @clustering_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @clustering_GUI_OutputFcn, ...
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


% --- Executes just before clustering_GUI is made visible.
function clustering_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to clustering_GUI (see VARARGIN)

% Choose default command line output for clustering_GUI
handles.output = hObject;

% Load the necessary data, modify and store in handles object...
try
    load('body_axis.mat')
    load('exclude_frames.mat')
    load('headloc.mat')
    
    handles.vars.head     = head_coords;
    handles.vars.proc_obj = proc_objects;
    handles.vars.orig_obj = orig_objects;
    handles.vars.filtdat  = sign(final_frames);
    handles.vars.final    = [];
        
    set(handles.mssg,'String','System message: all files loaded.');
catch
    set(handles.mssg,'String','System message: files missing.')
    set(handles.clusterStart,'Enable','off');
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes clustering_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = clustering_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function frames_n_Callback(hObject, eventdata, handles)
% hObject    handle to frames_n (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frames_n as text
%        str2double(get(hObject,'String')) returns contents of frames_n as a double


% --- Executes during object creation, after setting all properties.
function frames_n_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frames_n (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function overlap_n_Callback(hObject, eventdata, handles)
% hObject    handle to overlap_n (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of overlap_n as text
%        str2double(get(hObject,'String')) returns contents of overlap_n as a double


% --- Executes during object creation, after setting all properties.
function overlap_n_CreateFcn(hObject, eventdata, handles)
% hObject    handle to overlap_n (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in clusterStart.
function clusterStart_Callback(hObject, eventdata, handles)
% hObject    handle to clusterStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% read the text fields
framesnVal = round(str2double(get(handles.frames_n, 'String')));
overlapVal = round(str2double(get(handles.overlap_n,'String')));

% if the result of that is integer values larger than 0...
if ((framesnVal > 0) && (overlapVal > 0))

    set(handles.mssg,'String','System message: clustering...');
    drawnow();
    pause(0.01);
    proc = filter_objects_by_frame(handles.vars.filtdat,handles.vars.proc_obj);
    
    % cluster the objects
    [stor,~] = progressive_hierarchical_kmeans(proc,framesnVal,overlapVal);

    set(handles.mssg,'String','System message: consolidating clusters...');
    drawnow();
    pause(0.01);
    % organize the clusters
    metaclusters = meta_cluster(handles.vars.filtdat,stor);

    set(handles.mssg,'String','System message: mapping to data...');
    drawnow();
    pause(0.01);
    % figure out what the objects were originally
    [handles.vars.final,handles.vars.metaclusters] = match_clustered_objects(metaclusters,handles.vars.proc_obj,handles.vars.orig_obj);
    
    set(handles.mssg,'String','System message: DONE');
    drawnow();
    pause(0.01);
    % enable check results and exit buttons
    set(handles.exitButton,'Enable','on');
    set(handles.checkResultsButton,'Enable','on');

    % updata data structure
    guidata(hObject, handles);

end

% --- Executes on button press in checkResultsButton.
function checkResultsButton_Callback(hObject, eventdata, handles)
% hObject    handle to checkResultsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% h = play_movie_w_classified_objects(cd,handles.vars.final,handles.vars.head);
% assignin('base', 'the_objects', handles.vars.final);
% delete(h);
if ~isempty(handles.vars.final)
    the_objects  = handles.vars.final;
    metaclusters = handles.vars.metaclusters;
    save('automated_clustering_results.mat','the_objects','metaclusters');
    check_result_GUI;
end

% --- Executes on button press in exitButton.
function exitButton_Callback(hObject, eventdata, handles)
% hObject    handle to exitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% save what's worth saving
if ~isempty(handles.vars.final)
    the_objects  = handles.vars.final;
    metaclusters = handles.vars.metaclusters;
    save('automated_clustering_results.mat','the_objects','metaclusters');
    %check_result_GUI;
end

figure1_DeleteFcn(handles.figure1,eventdata,handles);

% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% exit
delete(hObject);
