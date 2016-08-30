function varargout = mapX(varargin)
% MAPX MATLAB code for mapX.fig
%      MAPX, by itself, creates a new MAPX or raises the existing
%      singleton*.
%
%      H = MAPX returns the handle to a new MAPX or the handle to
%      the existing singleton*.
%
%      MAPX('CALLBACK',hObject,eventData,h,...) calls the local
%      function named CALLBACK in MAPX.M with the given input arguments.
%
%      MAPX('Property','Value',...) creates a new MAPX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mapX_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mapX_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIh

% Edit the above text to modify the response to help mapX

% Last Modified by GUIDE v2.5 14-Oct-2014 23:40:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mapX_OpeningFcn, ...
                   'gui_OutputFcn',  @mapX_OutputFcn, ...
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
function mapX_OpeningFcn(hObject,eventdata,h,varargin)
%%
movegui(hObject,'center')

%Set the directory
if ~isempty(varargin)
    h.project_path = varargin{2};
else
    h.project_path = uigetdir(pwd,'Select Project Directory');
end

h.now = datestr(now,'yyyymmddHHMMSS');

disp('TREX-RT>> Launching MapX!');
disp(['TREX-RT>> Current time: ',h.now]);

[s,mess,messid] = mkdir(h.project_path,'Log');
%%
mainDir = fileparts(which('TREX'));
h.parameter_path = fullfile(mainDir,'mapX','Map Parameter Profiles');
h.profile = readcsvX(fullfile(h.parameter_path,'parameters_default.trex'));

h = parameterfields_mapX(h);
h = profileread_mapX(h,h.profile);

h.axes_wait = axes('Parent',h.figure_map,...
                   'XLim',[0 1],...
                   'YLim',[0 1],...
                   'XTick',[],...
                   'YTick',[],...
                   'Box','on',...
                   'Layer','top',...
                   'Units','pixels',...
                   'Position',[30 15 600 25]);

h.patch_wait = patch([0 0 0 0], [0 1 1 0], 'r',...
                     'Parent',h.axes_wait,...
                     'FaceColor','r',...
                     'EdgeColor','none');
                 
h.text_wait = text(565,15,'',...
                   'Parent',h.axes_wait,...
                   'Units','pixels',...
                   'Color','k',...
                   'Visible','on',...
                   'FontUnits','pixels',...
                   'FontSize',12);
               
h.text_wait2 = text(15,15,'',...
                    'Parent',h.axes_wait,...
                    'Units','pixels',...
                    'Color','k',...
                    'Visible','on',...
                    'FontUnits','pixels',...
                    'FontSize',12);

h.tableHeadings =  {'Project Path',        'project_path';...
                    'Server Name',          'server_name';...
                    'Server User',          'server_user';...
                    'Institution Dir',      'institution_dir';...
                    'Institution Name',     'institution_name';...
                    'Patient Dir',          'patient_dir';...
                    'Patient Name',         'patient_name';...
                    'MRN',                  'patient_mrn';...
                    'Plan Dir',             'plan_dir';...
                    'Plan Name',            'plan_name';...
                    'Image Name',           'image_name';...
                    'ROI Name',             'roi_name';...
                    'ROI Source',           'roi_source';...
                    'ROI Avoid Int',        'roi_int';...
                    'ROI Avoid Ext',        'roi_ext';...
                    'Dose Trial Name',      'dose_name'};
                
h.setupRead = read_setupX(h.project_path);

h.data = cell(numel(h.setupRead.project_path),size(h.tableHeadings,1));
for j = 1:size(h.tableHeadings,1)
    for i = 1:numel(h.setupRead.project_path)
    
        if iscell(h.setupRead.(h.tableHeadings{j,2})(i))
            h.data{i,j} = h.setupRead.(h.tableHeadings{j,2}){i};
        else
            h.data{i,j} = h.setupRead.(h.tableHeadings{j,2})(i);
        end
    end
end

set(h.table_data,'Visible','on');
set(h.table_data,'ColumnName',h.tableHeadings(:,1));
col_format = cell(1,numel(h.tableHeadings(:,1)));
col_format(:) = {'char'};
set(h.table_data,'ColumnFormat',col_format);
set(h.table_data,'Data',h.data);

if ~isempty(h.data)
    set(h.push_start,'Enable','on')
    disp('TREX-RT>> setupX.mat data added to table!');
else
    disp('TREX-RT>> No setupX.mat data exists. Select different project.');
end

h.notifier = false;
h.extract_go = false;
h.remote_start = false;

if numel(varargin) > 1
    for i = 1:numel(varargin)
        if strcmpi(varargin{i},'notify')
            notify = varargin{i+1};
            if strcmpi(notify,'on')
                h.notifier = true;
            end
            
        elseif strcmpi(varargin{i},'extract')
            h.extract_go = true;
            
        elseif strcmpi(varargin{i},'remote_start')
            h.remote_start = true;
        end
    end
end

clearvars -except h eventdata hObject

% Choose default command line output for mapX
h.output = hObject;

% Update h structure
guidata(hObject, h);

if h.remote_start
    push_start_Callback(hObject,eventdata,h)
else
    % UIWAIT makes mapX wait for user response (see UIRESUME)
    uiwait(h.figure_map);
end

%--------------------------------------------------------------------------
function varargout = mapX_OutputFcn(hObject,eventdata,h) 
%%
varargout{1} = h;

delete(h.figure_map);

%--------------------------------------------------------------------------
function figure_map_CloseRequestFcn(hObject,eventdata,h)
%%
if isequal(get(hObject, 'waitstatus'), 'waiting')
    uiresume(hObject);
else
    delete(hObject);
end

disp('TREX-RT>> MapX closed');

clear

%--------------------------------------------------------------------------
function table_data_CellSelectionCallback(hObject,eventdata,h)
%%
h.viewer = [];

set(h.menu_launchviewer,'Enable','on')

if ~isempty(h.data)
    set(h.table_data,'UserData',eventdata.Indices)
end

guidata(hObject,h)

%START*********************************************************************
%--------------------------------------------------------------------------
function push_start_Callback(hObject,eventdata,h)
%%
if ~strcmpi(h.setupRead.project_path{1},h.project_path)
    error('The current project_path does not match the path in the setup file...It is likely this project has been moved and needs to be migrated')
end

setupdate = getDate_logX(h.project_path,'setup');
extractdate = getDate_logX(h.project_path,'extract');

if extractdate < setupdate
    if h.extract_go
        if h.notifier
            h = notifierX(h.project_path,@start_pinnacle_extractX,h);
%             h = start_pinnacle_extractX(h);
        else
            h = start_pinnacle_extractX(h);
        end
    end

    pause(1);
end

h.extractRead = read_extractX(h.project_path);

if h.notifier
    h = notifierX(h.project_path,@start_mapX,h);
%     h = start_mapX(h);
else
    h = start_mapX(h);
end

clearvars -except h hObject

guidata(hObject,h)

% close(h.figure_map)

%MENU**********************************************************************
%--------------------------------------------------------------------------
function menu_file_Callback(hObject,eventdata,h)

%--------------------------------------------------------------------------
function menu_tparameters_Callback(hObject,eventdata,h)
%%
parameters = parameters_mapX(h.profile);

if ~isempty(parameters)
    for i = 1:numel(h.module_names)
       h.(h.module_names{i}) = parameters.(h.module_names{i}); 
    end
end

h.profile = profilewrite_mapX(h); 

clearvars -except h hObject

guidata(hObject,h);

%--------------------------------------------------------------------------
function menu_exit_Callback(hObject,eventdata,h)
%%
close(h.figure_map)

%--------------------------------------------------------------------------
function menu_utilities_Callback(hObject,eventdata,h)

%--------------------------------------------------------------------------
function menu_notify_Callback(hObject,eventdata,h)
%%
if strcmpi(get(hObject,'Checked'),'On')
    set(hObject,'Checked','Off')
    h.notifier = false;
else
    set(hObject,'Checked','On')
    h.notifier = true;
end

guidata(hObject,h);

%--------------------------------------------------------------------------
function menu_view_Callback(hObject,eventdata,h)

%--------------------------------------------------------------------------
function menu_launchviewer_Callback(hObject,eventdata,h)
%%
h.extractRead = read_extractX(h.project_path);

if isempty(h.extractRead)
    msgbox('No data has been extracted yet to be viewed!')
    return
end

index = get(h.table_data,'UserData');

if ~isempty(index)
    index = get(h.table_data,'UserData');
    
    if size(index,1) == 1
        h.viewer = index(1,1);
    else
        msgbox('Please select only one entry')
        return
    end 
end

drawnow; pause(0.001);

viewerX(h)

guidata(hObject,h)

%--------------------------------------------------------------------------
function menu_help_Callback(hObject,eventdata,h)
