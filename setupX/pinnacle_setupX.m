function varargout = pinnacle_setupX(varargin)
% PINNACLE_SETUPX MATLAB code for pinnacle_setupX.fig
%      PINNACLE_SETUPX, by itself, creates a new PINNACLE_SETUPX or raises the existing
%      singleton*.
%
%      H = PINNACLE_SETUPX returns the handle to a new PINNACLE_SETUPX or the handle to
%      the existing singleton*.
%
%      PINNACLE_SETUPX('CALLBACK',hObject,eventData,h,...) calls the local
%      function named CALLBACK in PINNACLE_SETUPX.M with the given input arguments.
%
%      PINNACLE_SETUPX('Property','Value',...) creates a new PINNACLE_SETUPX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pinnacle_setupX_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pinnacle_setupX_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIh

% Edit the above text to modify the response to help pinnacle_setupX

% Last Modified by GUIDE v2.5 05-Nov-2014 11:41:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pinnacle_setupX_OpeningFcn, ...
                   'gui_OutputFcn',  @pinnacle_setupX_OutputFcn, ...
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
function pinnacle_setupX_OpeningFcn(hObject,eventdata,h,varargin)
%%
movegui(hObject,'center')

h.export = [];
h.export = initialize_pinnacle_setupX(h.export);

mainDir = fileparts(which('TREX'));
ver = regexp(mainDir, filesep, 'split');
h.export.trex_setupver = ver{end};

%Set the directory
if ~isempty(varargin)
    h.export.project_path = varargin{2};
else
    h.export.project_path = uigetdir(pwd,'Select Project Directory');
end
% cd(h.export.project_path)

h.now = datestr(now,'yyyymmddHHMMSS');

[s,mess,messid] = mkdir(h.export.project_path,'Log');
diary(fullfile(h.export.project_path,'Log',[h.now,'_setupX.xlog']))

disp('TREX-RT>> Launching SetupX!');
disp(['TREX-RT>> Current time: ',h.now]);

h.filedata = [];
h.img = [];
h.roi = [];
h.dose = [];

h.imgtoggle = true;
set(h.menu_displayscan,'Checked','on')
h.roitoggle_curve = false;
h.dosetoggle = false;

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

h.setupWrite = read_setupX(h.export.project_path);
if isempty(h.setupWrite)
    h.setupWrite = initialize_pinnacle_setupX(h.setupWrite);
end
  
h.data = cell(numel(h.setupWrite.project_path),size(h.tableHeadings,1));
for j = 1:size(h.tableHeadings,1)
    for i = 1:numel(h.setupWrite.project_path)
        if iscell(h.setupWrite.(h.tableHeadings{j,2})(i))
            h.data{i,j} = h.setupWrite.(h.tableHeadings{j,2}){i};
        else
            h.data{i,j} = h.setupWrite.(h.tableHeadings{j,2})(i);
        end
    
    end
end

set(h.table_data,'Visible','on');
set(h.table_data,'ColumnName',h.tableHeadings(:,1));
col_format = cell(1,numel(h.tableHeadings(:,1)));
col_format(:) = {'char'};
set(h.table_data,'ColumnFormat',col_format);
set(h.table_data,'Data',h.data);
 
disp('TREX-RT>> setupX.mat data added to table!');

%%
h.h_names = {'drop_server',...
             'push_server',...
             'drop_institution',...
             'push_institution',...
             'drop_patient',...
             'push_patient',...
             'drop_plan',...
             'push_plan',...
             'drop_roi',...
             'push_scaninfo',...
             'push_displaycurveroi',...
             'drop_dose',...
             'push_doseinfo',...
             'push_displaydose',...
             'push_add',...
             'push_remove',...
             'table_data',...
             'slider_level',...
             'text_window',...
             'text_level',...
             'edit_level',...
             'edit_window',...
             'text_preset',...
             'drop_preset',...
             'slider_window',...
             'menu_file',...
             'menu_exit',...
             'menu_view',...
             'menu_displayscan',...
             'menu_displaycurveroi',...
             'menu_displaydose',...
             'menu_scaninfo',...
             'menu_doseinfo',...
             'menu_tools',...
             'menu_roiadvanced',...
             'menu_roisubvolumes',...
             'menu_script',...
             'menu_help',...
             'menu_about'};

%%
h.wl_presets = {'Lung',1600,500;...
                'Abdomen',400,1000;...
                'Bone',1400,1400;...
                'Breast',400,950;...
                'Head',180,1040;...
                'Neck',970,1430;...
                'Pelvis',500,1000;...
                'Thorax',400,1000;...
                'FDG',46,23;...
                'MR1',700,350;...
                'MR2',550,275;...
                'Ultrasound',200,100};
            
h.active = 'main';
h.view_main = 'a';
h.view_minor1 = 's';
h.view_minor2 = 'c';
% 
% set(h.drop_preset,'String',h.wl_presets(:,1))
% h.wl_current = 'Lung';
% ind = strcmpi(h.wl_current,h.wl_presets);
% 
% h.window = h.wl_presets{ind,2};
% h.level = h.wl_presets{ind,3};
% 
% set(h.edit_window,'String',num2str(h.window));
% set(h.slider_window,'Value',h.window);
% 
% set(h.slider_level,'Value',h.level);
% set(h.edit_level,'String',num2str(h.level));
% 
% bot = h.level-floor(h.window/2);
% if bot < 0
%     bot = 0;
% end
% top = h.level+ceil(h.window/2);
% if top > 4095
%     top = 4095;
% end
% h.range = [bot top];

axes_main_setupX(h)
axes_minor1_setupX(h)
axes_minor2_setupX(h)

%%
mainDir = fileparts(which('TREX'));
configPath = fullfile(mainDir,'config.trex');

fid = fopen(configPath);
config = textscan(fid,'%s','delimiter','\n');
config = config{1};
fclose(fid);

servers = textParserX(config,'pinnacle-server');
h.server_list = {'Local Pinnacle';servers};

set(h.drop_server,'Enable','on')
set(h.drop_server,'String',h.server_list)

%%
% Choose default command line output for pinnacle_setupX
h.output = hObject;

clearvars -except h hObject

% Update h structure
guidata(hObject,h)

% UIWAIT makes pinnacle_setupX wait for user response (see UIRESUME)
uiwait(h.figure_setup_pinnacle);

%--------------------------------------------------------------------------
function varargout = pinnacle_setupX_OutputFcn(hObject,eventdata,h) 
%%
varargout{1} = h;

delete(h.figure_setup_pinnacle);

%--------------------------------------------------------------------------
function figure_setup_pinnacle_CloseRequestFcn(hObject,eventdata,h)
%%
if isempty(h.data)
    try
        close(h.ftp);
    catch err

    end

    fclose('all');
    
    if isequal(get(hObject, 'waitstatus'), 'waiting')
        uiresume(hObject);
    else
        delete(hObject);
    end
    
    diary off
    disp(['TREX-RT>> Log file: ',h.now,'_setupX.xlog'])
    disp('TREX-RT>> setupX.xroi file not saved!')
    disp('TREX-RT>> SetupX closed');
    
    clear
    
else
    button1 = questdlg('Save setupX before exit?');

    if strcmpi(button1,'yes')
        save_setupX(h)
        
        try
            close(h.ftp);
        catch err

        end

        fclose('all');

        button2 = questdlg('Proceed to data extraction?');

        if strcmpi(button2,'yes') 
            if isequal(get(hObject, 'waitstatus'), 'waiting')
                uiresume(hObject);
            else
                delete(hObject);
            end
            
            diary off
            disp(['TREX-RT>> Log file: ',h.now,'_setupX.xlog'])
            disp('TREX-RT>> SetupX closed');

            extractX(1,h.export.project_path)

            clear

        elseif strcmpi(button2,'no')
            if isequal(get(hObject, 'waitstatus'), 'waiting')
                uiresume(hObject);
            else
                delete(hObject);
            end

            diary off
            disp(['TREX-RT>> Log file: ',h.now,'_setupX.xlog'])
            disp('TREX-RT>> SetupX closed');

            clear
        end

    elseif strcmpi(button1,'no')
        try
            close(h.ftp);
        catch err

        end

        fclose('all');
        disp('TREX-RT>> setupX.xroi file not saved!')
        
        if isequal(get(hObject, 'waitstatus'), 'waiting')
            uiresume(hObject);
        else
            delete(hObject);
        end

        diary off
        disp(['TREX-RT>> Log file: ',h.now,'_setupX.xlog'])
        disp('TREX-RT>> SetupX closed');

        clear
        
    end
end

%SERVER PANEL**************************************************************
%--------------------------------------------------------------------------
function drop_server_Callback(hObject,eventdata,h)
%%
h = drop_server_pinnacle_setupX(h);

guidata(hObject,h)

%--------------------------------------------------------------------------
function drop_server_CreateFcn(hObject,eventdata,h)
%%
if ispc && isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function push_server_Callback(hObject,eventdata,h)
%%
h = push_server_pinnacle_setupX(h);

guidata(hObject,h)

%INSTITUTION PANEL*********************************************************
%--------------------------------------------------------------------------
function drop_institution_Callback(hObject,eventdata,h)
%%
h = drop_institution_pinnacle_setupX(h);

guidata(hObject,h)

%--------------------------------------------------------------------------
function drop_institution_CreateFcn(hObject,eventdata,h)
%%
if ispc && isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function push_institution_Callback(hObject,eventdata,h)
%%
h = push_institution_pinnacle_setupX(h);

guidata(hObject,h)

%PATIENT PANEL*************************************************************
%--------------------------------------------------------------------------
function drop_patient_Callback(hObject,eventdata,h)
%%
h = drop_patient_pinnacle_setupX(h);

guidata(hObject,h)

%--------------------------------------------------------------------------
function drop_patient_CreateFcn(hObject,eventdata,h)
%%
if ispc && isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function push_patient_Callback(hObject,eventdata,h)
%%
h = push_patient_pinnacle_setupX(h);

guidata(hObject,h)

%PLAN PANEL****************************************************************
%--------------------------------------------------------------------------
function drop_plan_Callback(hObject,eventdata,h)
%%
h = drop_plan_pinnacle_setupX(h);

guidata(hObject,h)

%--------------------------------------------------------------------------
function drop_plan_CreateFcn(hObject,eventdata,h)
%%
if ispc && isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function push_plan_Callback(hObject,eventdata,h)
%%
h = push_plan_pinnacle_setupX(h);

guidata(hObject,h)

%--------------------------------------------------------------------------
function push_scaninfo_Callback(hObject,eventdata,h)
%%
view_scaninfo_pinnacle_setupX(h.export)

%ROI PANEL*****************************************************************
%--------------------------------------------------------------------------
function drop_roi_Callback(hObject,eventdata,h)
%%
h = drop_roi_pinnacle_setupX(h);

guidata(hObject,h)

%--------------------------------------------------------------------------
function drop_roi_CreateFcn(hObject,eventdata,h)
%%
if ispc && isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
 
%--------------------------------------------------------------------------
function push_displaycurveroi_Callback(hObject,eventdata,h)
%%
h = curveroi_update(h);

button_state = get(hObject,'Value');
if button_state == get(hObject,'Min')
    h.roitoggle_curve = false;
    set(h.menu_displaycurveroi,'Checked','off')
    set(hObject,'Value',0)
    
elseif button_state == get(hObject,'Max')
    h.roitoggle_curve = true;
    set(h.menu_displaycurveroi,'Checked','on')
    set(hObject,'Value',1)
end

axes_main_setupX(h)
axes_minor1_setupX(h)
axes_minor2_setupX(h)

guidata(hObject,h)

%--------------------------------------------------------------------------
function h = curveroi_update(h)
%%
if isempty(h.roi.curvedata)
    h = suspendhandles_pinnacle_setupX(h);
    h = readROI_pinnacle_setupX(h);
    h = scaleCurvedata_pinnacle_setupX(h);
    restorehandles_pinnacle_setupX(h)
end

%DOSE PANEL****************************************************************
%--------------------------------------------------------------------------
function drop_dose_Callback(hObject,eventdata,h)
%%
h = drop_dose_pinnacle_setupX(h);

guidata(hObject,h)

%--------------------------------------------------------------------------
function drop_dose_CreateFcn(hObject,eventdata,h)
%%
if ispc && isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function push_doseinfo_Callback(hObject,eventdata,h)
%%
view_doseinfo_pinnacle_setupX(h.dose)

%--------------------------------------------------------------------------
function push_displaydose_Callback(hObject,eventdata,h)
%%
h = dose_update(h);

button_state = get(hObject,'Value');
if button_state == get(hObject,'Min')
    h.dosetoggle = false;
    set(h.menu_displaydose,'Checked','off')
    set(hObject,'Value',0)
    
elseif button_state == get(hObject,'Max')
    h.dosetoggle = true;
    set(h.menu_displaydose,'Checked','on')
    set(hObject,'Value',1)
end

axes_main_setupX(h)
axes_minor1_setupX(h)
axes_minor2_setupX(h)
    
guidata(hObject,h)

%--------------------------------------------------------------------------
function [h] = dose_update(h)
%%
if isempty(h.dose.array)
    h = suspendhandles_pinnacle_setupX(h);
    h.dose.array = interpDose_pinnacle_setupX(h);
    restorehandles_pinnacle_setupX(h)
end


%ADD/REMOVE****************************************************************
%--------------------------------------------------------------------------
function push_add_Callback(hObject,eventdata,h)
%%
h = push_add_pinnacle_setupX(h);

guidata(hObject,h)

%--------------------------------------------------------------------------
function table_data_CellSelectionCallback(hObject,eventdata,h)
%%
if ~isempty(h.data)
    set(h.table_data,'UserData',eventdata.Indices)
    set(h.push_remove,'Enable','on') 
end

guidata(hObject,h)

%--------------------------------------------------------------------------
function push_remove_Callback(hObject,eventdata,h)
%%
index = get(h.table_data,'UserData');

if ~isempty(index)
    index = get(h.table_data,'UserData');
    
    for i = size(index,1):-1:1
        h.data(index(i,1),:) = [];
        
        sNames = fieldnames(h.setupWrite);
        for nCount = 1:numel(sNames)
            h.setupWrite.(sNames{nCount})(index(i,1),:) = [];
        end
    end
    set(h.table_data,'Data',h.data); 
end

pause(0.001)

set(h.push_remove,'Enable','off')

disp('TREX-RT>> Entry removed');
    
guidata(hObject,h)

%W/L PANEL*****************************************************************
%--------------------------------------------------------------------------
function drop_preset_Callback(hObject,eventdata,h)
%%
contents = cellstr(get(hObject,'String'));
h.wl_current = contents{get(hObject,'Value')};

h.window = h.wl_presets{get(hObject,'Value'),2};
h.level = h.wl_presets{get(hObject,'Value'),3};

set(h.edit_window,'String',num2str(h.window));
set(h.slider_window,'Value',h.window);

set(h.slider_level,'Value',h.level);
set(h.edit_level,'String',num2str(h.level));

bot = h.level-floor(h.window/2);
if bot < 0
    bot = 0;
end
top = h.level+ceil(h.window/2);
if top > 4095
    top = 4095;
end
h.range = [bot top];

axes_main_setupX(h)
axes_minor1_setupX(h)
axes_minor2_setupX(h)

guidata(hObject,h)

%--------------------------------------------------------------------------
function drop_preset_CreateFcn(hObject,eventdata,h)
%%
if ispc && isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function edit_window_Callback(hObject,eventdata,h)
%%
window = round(str2double(get(hObject,'String')));
if isnan(window)
    set(hObject,'String',h.window);
    errordlg('Input must be a number','Error')
else
    h.window = window;
    
    set(h.slider_window,'Value',h.window);
    
    bot = h.level-floor(h.window/2);
    if bot < 0
        bot = 0;
    end
    top = h.level+ceil(h.window/2);
    if top > 4095
        top = 4095;
    end
    h.range = [bot top];
end

axes_main_setupX(h)
axes_minor1_setupX(h)
axes_minor2_setupX(h)

guidata(hObject,h)

%--------------------------------------------------------------------------.
function edit_window_CreateFcn(hObject,eventdata,h)
%%
if ispc && isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function slider_window_Callback(hObject,eventdata,h)
%%
h.window = round(get(hObject,'Value'));

set(h.edit_window,'String',num2str(h.window));

bot = h.level-floor(h.window/2);
if bot < 0
    bot = 0;
end
top = h.level+ceil(h.window/2);
if top > 4095
    top = 4095;
end
h.range = [bot top];

axes_main_setupX(h)
axes_minor1_setupX(h)
axes_minor2_setupX(h)

guidata(hObject,h)

%--------------------------------------------------------------------------
function slider_window_CreateFcn(hObject,eventdata,h)
%%
if isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%--------------------------------------------------------------------------
function edit_level_Callback(hObject,eventdata,h)
%%
level = round(str2double(get(hObject,'String')));
if isnan(level)
    set(hObject,'String',h.level);
    errordlg('Input must be a number','Error')
else
    h.level = level;
    
    set(h.slider_level,'Value',h.level);
    
    bot = h.level-floor(h.window/2);
    if bot < 0
        bot = 0;
    end
    top = h.level+ceil(h.window/2);
    if top > 4095
        top = 4095;
    end
    h.range = [bot top];
end

axes_main_setupX(h)
axes_minor1_setupX(h)
axes_minor2_setupX(h)

guidata(hObject,h)

%--------------------------------------------------------------------------
function edit_level_CreateFcn(hObject,eventdata,h)
%%
if ispc && isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function slider_level_Callback(hObject,eventdata,h)
%%
h.level = round(get(hObject,'Value'));

set(h.edit_level,'String',num2str(h.level));

bot = h.level-floor(h.window/2);
if bot < 0
    bot = 0;
end
top = h.level+ceil(h.window/2);
if top > 4095
    top = 4095;
end
h.range = [bot top];

axes_main_setupX(h)
axes_minor1_setupX(h)
axes_minor2_setupX(h)

guidata(hObject,h)

%--------------------------------------------------------------------------
function slider_level_CreateFcn(hObject,eventdata,h)
%%
if isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%VIEWER DISPLAY************************************************************
%--------------------------------------------------------------------------
function figure_setup_pinnacle_KeyPressFcn(hObject,eventdata,h)
%%
key = eventdata.Key;

if strcmpi(h.active,'main')
    if strcmp(key,'uparrow')
        %And we're not out of bounds
        if (strcmp(h.view_main,'a') && h.main_z < h.export.image_zdim) 
            h.main_z = h.main_z+1;
        elseif (strcmp(h.view_main,'c') && h.main_y < h.export.image_ydim)
            h.main_y = h.main_y+1;
        elseif (strcmp(h.view_main,'s') && h.main_x < h.export.image_xdim)
            h.main_x = h.main_x+1;
        end
    %If the down arrow or mouse wheel is turned
    elseif strcmp(key,'downarrow')
        %And we're not out of bounds
        if (strcmp(h.view_main,'a') && h.main_z > 1) 
            h.main_z = h.main_z-1;
        elseif (strcmp(h.view_main,'c') && h.main_y > 1)
            h.main_y = h.main_y-1;
        elseif (strcmp(h.view_main,'s') && h.main_x > 1)
            h.main_x = h.main_x-1; 
        end
    elseif strcmp(key,'a')
        h.view_main = 'a';
    elseif strcmp(key,'s')
        h.view_main = 's'; 
    elseif strcmp(key,'c')
        h.view_main = 'c';
    end

    axes_main_setupX(h);

elseif strcmpi(h.active,'minor1')
    if strcmp(key,'uparrow')
        %And we're not out of bounds
        if (strcmp(h.view_minor1,'a') && h.minor1_z < h.export.image_zdim) 
            h.minor1_z = h.minor1_z+1;
        elseif (strcmp(h.view_minor1,'c') && h.minor1_y < h.export.image_ydim)
            h.minor1_y = h.minor1_y+1;
        elseif (strcmp(h.view_minor1,'s') && h.minor1_x < h.export.image_xdim)
            h.minor1_x = h.minor1_x+1;
        end
    %If the down arrow or mouse wheel is turned
    elseif strcmp(key,'downarrow')
        %And we're not out of bounds
        if (strcmp(h.view_minor1,'a') && h.minor1_z > 1) 
            h.minor1_z = h.minor1_z-1;
        elseif (strcmp(h.view_minor1,'c') && h.minor1_y > 1)
            h.minor1_y = h.minor1_y-1;
        elseif (strcmp(h.view_minor1,'s') && h.minor1_x > 1)
            h.minor1_x = h.minor1_x-1; 
        end
    elseif strcmp(key,'a')
        h.view_minor1 = 'a';
    elseif strcmp(key,'s')
        h.view_minor1 = 's'; 
    elseif strcmp(key,'c')
        h.view_minor1 = 'c';
    end

    axes_minor1_setupX(h)

 elseif strcmpi(h.active,'minor2')
    if strcmp(key,'uparrow')
        %And we're not out of bounds
        if (strcmp(h.view_minor2,'a') && h.minor2_z < h.export.image_zdim) 
            h.minor2_z = h.minor2_z+1;
        elseif (strcmp(h.view_minor2,'c') && h.minor2_y < h.export.image_ydim)
            h.minor2_y = h.minor2_y+1;
        elseif (strcmp(h.view_minor2,'s') && h.minor2_x < h.export.image_xdim)
            h.minor2_x = h.minor2_x+1;
        end
    %If the down arrow or mouse wheel is turned
    elseif strcmp(key,'downarrow')
        %And we're not out of bounds
        if (strcmp(h.view_minor2,'a') && h.minor2_z > 1) 
            h.minor2_z = h.minor2_z-1;
        elseif (strcmp(h.view_minor2,'c') && h.minor2_y > 1)
            h.minor2_y = h.minor2_y-1;
        elseif (strcmp(h.view_minor2,'s') && h.minor2_x > 1)
            h.minor2_x = h.minor2_x-1; 
        end
    elseif strcmp(key,'a')
        h.view_minor2 = 'a';
    elseif strcmp(key,'s')
        h.view_minor2 = 's'; 
    elseif strcmp(key,'c')
        h.view_minor2 = 'c';
    end

    axes_minor2_setupX(h)
end

guidata(hObject,h)

%--------------------------------------------------------------------------
function figure_setup_pinnacle_WindowScrollWheelFcn(hObject,eventdata,h)
%%
key = eventdata.VerticalScrollCount;

if strcmpi(h.active,'main')
    if sum(key) == -1
        %And we're not out of bounds
        if (strcmp(h.view_main,'a') && h.main_z < h.export.image_zdim) 
            h.main_z = h.main_z+1;
        elseif (strcmp(h.view_main,'c') && h.main_y < h.export.image_ydim)
            h.main_y = h.main_y+1;
        elseif (strcmp(h.view_main,'s') && h.main_x < h.export.image_xdim)
            h.main_x = h.main_x+1;
        end
    %If the down arrow or mouse wheel is turned
    elseif sum(key) == 1
        %And we're not out of bounds
        if (strcmp(h.view_main,'a') && h.main_z > 1) 
            h.main_z = h.main_z-1;
        elseif (strcmp(h.view_main,'c') && h.main_y > 1)
            h.main_y = h.main_y-1;
        elseif (strcmp(h.view_main,'s') && h.main_x > 1)
            h.main_x = h.main_x-1; 
        end
    end

    axes_main_setupX(h);
        
elseif strcmpi(h.active,'minor1')
    if sum(key) == -1
        %And we're not out of bounds
        if (strcmp(h.view_minor1,'a') && h.minor1_z < h.export.image_zdim) 
            h.minor1_z = h.minor1_z+1;
        elseif (strcmp(h.view_minor1,'c') && h.minor1_y < h.export.image_ydim)
            h.minor1_y = h.minor1_y+1;
        elseif (strcmp(h.view_minor1,'s') && h.minor1_x < h.export.image_xdim)
            h.minor1_x = h.minor1_x+1;
        end
    %If the down arrow or mouse wheel is turned
    elseif sum(key) == 1
        %And we're not out of bounds
        if (strcmp(h.view_minor1,'a') && h.minor1_z > 1) 
            h.minor1_z = h.minor1_z-1;
        elseif (strcmp(h.view_minor1,'c') && h.minor1_y > 1)
            h.minor1_y = h.minor1_y-1;
        elseif (strcmp(h.view_minor1,'s') && h.minor1_x > 1)
            h.minor1_x = h.minor1_x-1; 
        end
    end

    axes_minor1_setupX(h)

 elseif strcmpi(h.active,'minor2')
    if sum(key) == -1
        %And we're not out of bounds
        if (strcmp(h.view_minor2,'a') && h.minor2_z < h.export.image_zdim) 
            h.minor2_z = h.minor2_z+1;
        elseif (strcmp(h.view_minor2,'c') && h.minor2_y < h.export.image_ydim)
            h.minor2_y = h.minor2_y+1;
        elseif (strcmp(h.view_minor2,'s') && h.minor2_x < h.export.image_xdim)
            h.minor2_x = h.minor2_x+1;
        end
    %If the down arrow or mouse wheel is turned
    elseif sum(key) == 1
        %And we're not out of bounds
        if (strcmp(h.view_minor2,'a') && h.minor2_z > 1) 
            h.minor2_z = h.minor2_z-1;
        elseif (strcmp(h.view_minor2,'c') && h.minor2_y > 1)
            h.minor2_y = h.minor2_y-1;
        elseif (strcmp(h.view_minor2,'s') && h.minor2_x > 1)
            h.minor2_x = h.minor2_x-1; 
        end
    end

    axes_minor2_setupX(h)
end

guidata(hObject,h)

%--------------------------------------------------------------------------
function figure_setup_pinnacle_WindowButtonDownFcn(hObject,eventdata,h)
%%
mainpos = get(h.axes_main,'Position');
mainx = [mainpos(1) mainpos(1)+mainpos(3)];
mainy = [mainpos(2) mainpos(2)+mainpos(4)];

minor1pos = get(h.axes_minor1,'Position');
minor1x = [minor1pos(1) minor1pos(1)+minor1pos(3)];
minor1y = [minor1pos(2) minor1pos(2)+minor1pos(4)];

minor2pos = get(h.axes_minor2,'Position');
minor2x = [minor2pos(1) minor2pos(1)+minor2pos(3)];
minor2y = [minor2pos(2) minor2pos(2)+minor2pos(4)];

pt = get(hObject,'currentpoint');
x = pt(1);
y = pt(2);

if x > mainx(1) && x < mainx(2) && y > mainy(1) && y < mainy(2)
    h.active = 'main';
elseif x > minor1x(1) && x < minor1x(2) && y > minor1y(1) && y < minor1y(2)
    h.active = 'minor1';
elseif x > minor2x(1) && x < minor2x(2) && y > minor2y(1) && y < minor2y(2)
    h.active = 'minor2';
else
    h.active = [];
end
    
guidata(hObject,h)

%--------------------------------------------------------------------------
function figure_setup_pinnacle_WindowButtonUpFcn(hObject,eventdata,h)
%%
if strcmpi(h.active,'main')
    text_push1 = getappdata(h.axes_main,'push1');
    text_push2 = getappdata(h.axes_main,'push2');
    text_push3 = getappdata(h.axes_main,'push3');

    set(text_push1,'Visible','off')
    set(text_push2,'Visible','off')
    set(text_push3,'Visible','off')
    
elseif strcmpi(h.active,'minor1')
    text_push1 = getappdata(h.axes_minor1,'push1');
    text_push2 = getappdata(h.axes_minor1,'push2');
    text_push3 = getappdata(h.axes_minor1,'push3');

    set(text_push1,'Visible','off')
    set(text_push2,'Visible','off')
    set(text_push3,'Visible','off')
    
elseif strcmpi(h.active,'minor2')
    text_push1 = getappdata(h.axes_minor2,'push1');
    text_push2 = getappdata(h.axes_minor2,'push2');
    text_push3 = getappdata(h.axes_minor2,'push3');

    set(text_push1,'Visible','off')
    set(text_push2,'Visible','off')
    set(text_push3,'Visible','off')
end

guidata(hObject,h)

%MENU**********************************************************************
%--------------------------------------------------------------------------
function menu_file_Callback(hObject,eventdata,h)

%--------------------------------------------------------------------------
function menu_exit_Callback(hObject,eventdata,h)

%--------------------------------------------------------------------------
function menu_view_Callback(hObject,eventdata,h)

%--------------------------------------------------------------------------
function menu_displayscan_Callback(hObject,eventdata,h)
%%
check = get(hObject,'Checked');
if strcmpi(check,'on')
    h.imgtoggle = false;
    set(hObject,'Checked','off')
else
    h.imgtoggle = true;
    set(hObject,'Checked','on')
end

axes_main_setupX(h)
axes_minor1_setupX(h)
axes_minor2_setupX(h)
    
guidata(hObject,h)

%--------------------------------------------------------------------------
function menu_displaycurveroi_Callback(hObject,eventdata,h)
%%
h = curveroi_update(h);

check = get(hObject,'Checked');
if strcmpi(check,'on')
    h.roitoggle_curve = false;
    set(hObject,'Checked','off')
    set(h.push_displaycurveroi,'Value',0)
else
    h.roitoggle_curve = true;
    set(hObject,'Checked','on')
    set(h.push_displaycurveroi,'Value',1)
end

axes_main_setupX(h)
axes_minor1_setupX(h)
axes_minor2_setupX(h)

guidata(hObject,h)

%--------------------------------------------------------------------------
function menu_displaydose_Callback(hObject,eventdata,h)
%%
h = dose_update(h);

check = get(hObject,'Checked');
if strcmpi(check,'on')
    h.dosetoggle = false;
    set(hObject,'Checked','off')
    set(h.push_displaydose,'Value',0)
else
    h.dosetoggle = true;
    set(hObject,'Checked','on')
    set(h.push_displaydose,'Value',1)
end

axes_main_setupX(h)
axes_minor1_setupX(h)
axes_minor2_setupX(h)

guidata(hObject,h)

%--------------------------------------------------------------------------
function menu_scaninfo_Callback(hObject,eventdata,h)
%%
view_scaninfo_pinnacle_setupX(h.export)

%--------------------------------------------------------------------------
function menu_doseinfo_Callback(hObject,eventdata,h)
%%
view_doseinfo_pinnacle_setupX(h.dose)

%--------------------------------------------------------------------------
function menu_tools_Callback(hObject,eventdata,h)

%--------------------------------------------------------------------------
function menu_roiadvanced_Callback(hObject,eventdata,h)
%%
h = suspendhandles_pinnacle_setupX(h);

[name,source,int,ext,h.dose.interpArray] = advanced_pinnacle_setupX(h);

if ~isempty(name)
    for i = 1:length(name)
        h.export.roi_name = name{i};
        h.export.roi_source = source{i};
        h.export.roi_int = int{i};
        h.export.roi_ext = ext{i};

        h = push_add_pinnacle_setupX(h);
    end
end

set(h.drop_roi,'String',{' '})
set(h.drop_roi,'Value',1)
set(h.drop_roi,'String',h.roi_namelist);

h.roitoggle_curve = false;
set(h.push_displaycurveroi,'Enable','off')
set(h.push_displaycurveroi,'Value',0)
set(h.menu_displaycurveroi,'Enable','off')
set(h.menu_displaycurveroi,'Checked','off')

set(h.push_add,'Enable','off')

restorehandles_pinnacle_setupX(h)

guidata(hObject,h)

%%
clearvars -except h hObject

% --------------------------------------------------------------------
function menu_roisubvolumes_Callback(hObject,eventdata,h)
%%
[name,source,int,ext] = subvolumes_pinnacle_setupX(1,h.roi_namelist);

if ~isempty(name)
    for i = 1:length(name)
        h.export.roi_name = name{i};
        h.export.roi_source = source{i};
        h.export.roi_int = int{i};
        h.export.roi_ext = ext{i};

        h = push_add_pinnacle_setupX(h);
    end
end

set(h.drop_roi,'String',{' '})
set(h.drop_roi,'Value',1)
set(h.drop_roi,'String',h.roi_namelist);

h.roitoggle_curve = false;
set(h.push_displaycurveroi,'Enable','off')
set(h.push_displaycurveroi,'Value',0)
set(h.menu_displaycurveroi,'Enable','off')
set(h.menu_displaycurveroi,'Checked','off')

set(h.push_add,'Enable','off')

guidata(hObject,h)
%%
clearvars -except h hObject

%--------------------------------------------------------------------------
function menu_script_Callback(hObject,eventdata,h)
%%
mainDir = fileparts(fileparts(which('pinnacle_setupX')));
scriptDir = fullfile(mainDir,'setupX','pinnacle_setupX','pinnacle_setup_script');

filename = uigetfile(fullfile(scriptDir,'*.m'));

if filename ~= 0
    filename = strrep(filename,'.m','');
    fh = str2func(filename);

    try
        [name,source,int,ext] = fh(h);

        if ~isempty(name)
            for i = 1:length(name)
                h.export.roi_name = name{i};
                h.export.roi_source = source{i};
                h.export.roi_int = int{i};
                h.export.roi_ext = ext{i};

                h = push_add_pinnacle_setupX(h);
            end
        end

        set(h.drop_roi,'String',{' '})
        set(h.drop_roi,'Value',1)
        set(h.drop_roi,'String',h.roi_namelist);

        h.roitoggle_curve = false;
        set(h.push_displaycurveroi,'Enable','off')
        set(h.push_displaycurveroi,'Value',0)
        set(h.menu_displaycurveroi,'Enable','off')
        set(h.menu_displaycurveroi,'Checked','off')

        set(h.push_add,'Enable','off')

    catch err
    end
end

guidata(hObject,h)

%%
clearvars -except h hObject

%--------------------------------------------------------------------------
function menu_help_Callback(hObject,eventdata,h)

%--------------------------------------------------------------------------
function menu_about_Callback(hObject,eventdata,h)
