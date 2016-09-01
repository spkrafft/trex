function varargout = addjobX(varargin)
% ADDJOBX MATLAB code for addjobX.fig
%      ADDJOBX, by itself, creates a new ADDJOBX or raises the existing
%      singleton*.
%
%      H = ADDJOBX returns the handle to a new ADDJOBX or the handle to
%      the existing singleton*.
%
%      ADDJOBX('CALLBACK',hObject,eventData,h,...) calls the local
%      function named CALLBACK in ADDJOBX.M with the given input arguments.
%
%      ADDJOBX('Property','Value',...) creates a new ADDJOBX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before addjobX_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to addjobX_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIh

% Edit the above text to modify the response to help addjobX

% Last Modified by GUIDE v2.5 16-Mar-2015 12:34:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @addjobX_OpeningFcn, ...
                   'gui_OutputFcn',  @addjobX_OutputFcn, ...
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


%--------------------------------------------------------------------------
function addjobX_OpeningFcn(hObject,eventdata,h,varargin)

movegui(hObject,'center')

if ~isempty(varargin)
    h.default_directory = varargin{1};
else
    mainDir = fileparts(which('TREX'));
    configPath = fullfile(mainDir,'config.trex');
    
    fid = fopen(configPath);
    config = textscan(fid,'%s','delimiter','\n');
    config = config{1};
    fclose(fid);

    h.default_directory = textParserX(config,'default-directory');
end

h.selected_project = [];
h.selected_directory = h.default_directory;
set(h.push_dir,'String',h.default_directory)

h = updateProjects(h);
    
% Choose default command line output for addjobX
h.output = hObject;

% Update h structure
guidata(hObject, h);

% UIWAIT makes addjobX wait for user response (see UIRESUME)
uiwait(h.figure_addbatch);

%--------------------------------------------------------------------------
function varargout = addjobX_OutputFcn(hObject,eventdata,h) 

varargout{1} = [];
varargout{2} = [];

if isempty(h.selected_project) || strcmpi(h.selected_project,'')
    
else
    dose = get(h.box_dose,'Value');
    texture = get(h.box_texture,'Value');
    map = get(h.box_map,'Value');
    
    log = get(h.radio_cleanlog_yes,'Value');
    proj = get(h.radio_cleanproj_yes,'Value');
    update = get(h.radio_update_yes,'Value');
    
    work = [dose,texture,map,log,proj,update];
    
    if sum(work) ~= 0
        varargout{1} = fullfile(h.selected_directory,h.selected_project);
        
        work_cell = cell(repmat({'N'},1,6));
        ind = find(work==1);
        for i = 1:numel(ind)
            work_cell{ind(i)} = 'Y';
        end
        
        varargout{2} = work_cell;
    else
        
    end
end

delete(h.figure_addbatch);

%--------------------------------------------------------------------------
function figure_addbatch_CloseRequestFcn(hObject,eventdata,h)

if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end

clear

%--------------------------------------------------------------------------
function push_dir_Callback(hObject,eventdata,h)

selected_directory = uigetdir(h.default_directory);

if selected_directory ~= 0
    h.selected_directory = selected_directory;
    set(h.push_dir,'String',h.selected_directory);

    h = updateProjects(h);
end

guidata(hObject, h);

%--------------------------------------------------------------------------
function box_dose_Callback(hObject,eventdata,h)

%--------------------------------------------------------------------------
function box_map_Callback(hObject,eventdata,h)

%--------------------------------------------------------------------------
function box_texture_Callback(hObject,eventdata,h)

%--------------------------------------------------------------------------
function table_proj_CellSelectionCallback(hObject,eventdata,h)

set(h.table_proj,'UserData',eventdata.Indices)
index = get(h.table_proj,'UserData');

if ~isempty(index)
    index = get(h.table_proj,'UserData');
    
    if size(index,1) == 1
        h.selected_project = h.available_projects{index(1,1)};
    end
end

guidata(hObject, h);

%--------------------------------------------------------------------------
function [h] = updateProjects(h)

h.available_projects = cell(0);

list = dir(h.selected_directory);
isub = [list(:).isdir];
list = list(isub);
for count_dirs = 1:numel(list)
    if exist(fullfile(h.selected_directory,list(count_dirs).name,'Log'),'dir')
        h.available_projects{end+1,1} = list(count_dirs).name;
    end
end

set(h.table_proj,'Data',[])
set(h.table_proj,'Data',h.available_projects)
set(h.table_proj,'ColumnWidth',{350});

pause(0.01); drawnow;
