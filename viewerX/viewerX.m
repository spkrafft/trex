function varargout = viewerX(varargin)
% VIEWERX MATLAB code for viewerX.fig
%      VIEWERX, by itself, creates a new VIEWERX or raises the existing
%      singleton*.
%
%      H = VIEWERX returns the handle to a new VIEWERX or the handle to
%      the existing singleton*.
%
%      VIEWERX('CALLBACK',hObject,eventData,h,...) calls the local
%      function named CALLBACK in VIEWERX.M with the given input arguments.
%
%      VIEWERX('Property','Value',...) creates a new VIEWERX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before viewerX_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to viewerX_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIh

% Edit the above text to modify the response to help viewerX

% Last Modified by GUIDE v2.5 18-May-2016 14:07:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @viewerX_OpeningFcn, ...
                   'gui_OutputFcn',  @viewerX_OutputFcn, ...
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
function viewerX_OpeningFcn(hObject,eventdata,h,varargin)
%%
g = varargin{1};

%%
% This is here because the selected entry comes from the setup file and
% this is an entry which may or may not have been extracted...so we look
% for the extracted data first
ind_mrn = g.extractRead.patient_mrn == g.setupRead.patient_mrn(g.viewer);
ind_plan = strcmpi(g.extractRead.plan_name,g.setupRead.plan_name(g.viewer));
ind_imageUID = strcmpi(g.extractRead.image_internalUID,g.setupRead.image_internalUID(g.viewer));
ind_roiname = strcmpi(g.extractRead.roi_name,g.setupRead.roi_name(g.viewer));
ind_roiUID = strcmpi(g.extractRead.roi_internalUID,g.setupRead.roi_internalUID(g.viewer));

%Unique doesn't like it if dose_name is a cell array of empty arrays...it
%expects a cell array of strings...so that is what I am going to give it by
%assigning all entries without a dose_name as 'empty'
doseUID_setup = g.setupRead.dose_internalUID(g.viewer);
doseUID_extract = g.extractRead.dose_internalUID;
empty_setup = cellfun(@isempty,doseUID_setup);
empty_extract = cellfun(@isempty,doseUID_extract);
doseUID_setup(empty_setup)= {'empty'};
doseUID_extract(empty_extract)= {'empty'};
ind_doseUID = strcmpi(doseUID_setup,doseUID_extract);

dosename_setup = g.setupRead.dose_name(g.viewer);
dosename_extract = g.extractRead.dose_name;
empty_setup = cellfun(@isempty,dosename_setup);
empty_extract = cellfun(@isempty,dosename_extract);
dosename_setup(empty_setup)= {'empty'};
dosename_extract(empty_extract)= {'empty'};
ind_dosename = strcmpi(dosename_setup,dosename_extract);

found = ind_mrn & ind_plan & ind_imageUID & ind_roiname & ind_roiUID & ind_dosename & ind_doseUID;

if sum(found) ~= 1
    msgbox('Data for the selected entry has not been extracted!')
    return
else
    entry = find(found == 1);
end

h.entry = [];
eNames = fieldnames(g.extractRead);
for nCount = 1:numel(eNames)
    if iscell(g.extractRead.(eNames{nCount})(entry,:))
        h.entry.(eNames{nCount}) = g.extractRead.(eNames{nCount}){entry,:};
    else
        h.entry.(eNames{nCount}) = g.extractRead.(eNames{nCount})(entry,:);
    end
end

%%
clear g

%% Load IMAGE
h.entry.project_patient = fullfile(h.entry.project_path,num2str(h.entry.patient_mrn));
h.entry.project_pinndata = fullfile(h.entry.project_patient,'Pinnacle Data');
h.entry.project_scandata = fullfile(h.entry.project_pinndata,['CT.',h.entry.image_internalUID]);
h.entry.image_file = ['CT.',h.entry.image_internalUID,'.mat'];

try
    h.img = load(fullfile(h.entry.project_patient,h.entry.image_file));
catch err
    msgbox('Data has not been extracted!')
    return
end

set(h.menu_displayscan,'Enable','on')
set(h.push_displayscan,'Visible','on')
set(h.push_displayscan,'Enable','on')

set(h.menu_scaninfo,'Enable','on')

%% Load ROI
h.entry.project_roidata = fullfile(h.entry.project_pinndata,['ROI.',h.entry.roi_internalUID]);
h.entry.roi_file = ['ROI.',h.entry.roi_name,'.',h.entry.roi_internalUID,'.mat'];

try   
    h.roi = load(fullfile(h.entry.project_patient,h.entry.roi_file),'mask');
    h.roi.curvedata = [];
    
    set(h.menu_displaymaskroi,'Enable','on')
    set(h.push_displaymaskroi,'Visible','on')
    set(h.push_displaymaskroi,'Enable','on')

    set(h.menu_displaycurveroi,'Enable','on')
    set(h.push_displaycurveroi,'Visible','on')
    set(h.push_displaycurveroi,'Enable','on')

catch err
    msgbox('ROI for the selected entry has not been calculated!')
end
%%                                         


%% Load DOSE
h.entry.project_dosedata = fullfile(h.entry.project_pinndata,['DOSE.',h.entry.dose_internalUID]);
h.entry.dose_file = ['DOSE.',h.entry.dose_internalUID,'.mat'];  

try
    h.dose = load(fullfile(h.entry.project_patient,h.entry.dose_file),'array','array_xV','array_yV','array_zV');
    
    set(h.menu_displaydose,'Enable','on')
    set(h.push_displaydose,'Visible','on')
    set(h.push_displaydose,'Enable','on')

    set(h.menu_doseinfo,'Enable','on')

catch err
    %no dose available
end

%% Load MAPS

h.map_parameter = parameterfields_mapX([]);
h.map_files = cell(0);
h.map_files_module = cell(0);

for mCount = 1:numel(h.map_parameter.module_names)

    module = h.map_parameter.module_names{mCount};
    h.map_parameter.(module) = feval([module,'_features'],1);
    
    map_files = findmapfiles_mapX(h.entry.project_path,module);       
    ind_map_entry = ~cellfun(@isempty,regexpi(map_files,h.entry.roi_file));
    map_files = map_files(ind_map_entry);
    map_files_module = repmat({module},[sum(ind_map_entry),1]);
    
    h.map_files = [h.map_files; map_files];
    h.map_files_module = [h.map_files_module; map_files_module];
    
%     h.map_files = [h.map_files; findmapfiles_mapX(h.entry.project_path,module)];       
%     ind_map_entry = ~cellfun(@isempty,regexpi(h.map_files,h.entry.roi_file));
%     h.map_files = h.map_files(ind_map_entry);
%     h.map_files_module = [h.map_files_module; repmat({module},[sum(ind_map_entry),1])];
    
    if isempty(h.map_files)
        continue
    end
 
    h.map_fileshort = strrep(h.map_files,['.',h.entry.roi_file],'');
    
    set(h.pop_mapfile,'Visible','on')
    set(h.pop_mapfile,'Enable','on')
    set(h.pop_mapfile,'String',h.map_fileshort)

    set(h.push_displaymap,'Visible','on')
    
%     set(h.pop_mapfeature,'Visible','on')
%     set(h.pop_mapfeature,'Enable','on')
%     set(h.pop_mapfeature,'String',{' '})
    
    set(h.menu_mapinfo,'Enable','on')
end

%%
txt = sprintf(['Patient: ',h.entry.patient_name,'\n',...
               'MRN: ',num2str(h.entry.patient_mrn),'\n',...
               'Plan: ',h.entry.plan_name,'\n',...
               'Image: ',h.entry.image_patientname,'\n',...
               'ROI: ',h.entry.roi_name,'\n',...
               'Dose: ',h.entry.dose_name,'\n']);
set(h.text_info,'String',txt)

%%
h.h_names = {'menu_view',...
             'menu_file',...
             'menu_mapinfo',...
             'menu_doseinfo',...
             'menu_scaninfo',...
             'menu_displaymap',...
             'menu_displaydose',...
             'menu_displaycurveroi',...
             'menu_displaymaskroi',...
             'menu_displayscan',...
             'menu_exit',...
             'pop_mapfile',...
             'pop_mapfeature',...
             'push_displaymap',...
             'push_displaydose',...
             'push_displaycurveroi',...
             'push_displaymaskroi',...
             'push_displayscan',...
             'slider_level',...
             'text_window',...
             'text_level',...
             'edit_level',...
             'edit_window',...
             'text_preset',...
             'drop_preset',...
             'slider_window'};
        
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
            
%%
movegui(hObject,'center')

% Choose default command line output for viewerX
h.output = hObject;

clearvars -except h hObject

% Update h structure
guidata(hObject,h);

initialize(hObject,h)

% UIWAIT makes viewerX wait for user response (see UIRESUME)
uiwait(h.figure_viewer);

%--------------------------------------------------------------------------
function varargout = viewerX_OutputFcn(hObject,eventdata,h) 
%%
varargout{1} = h;

delete(h.figure_viewer);

%--------------------------------------------------------------------------
function figure_viewer_CloseRequestFcn(hObject,eventdata,h)
%%
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end

%--------------------------------------------------------------------------
function initialize(hObject, h)
%%
h.active = 'main';
h.view_main = 'a';
h.view_minor1 = 's';
h.view_minor2 = 'c';

h.imgtoggle = 1;
set(h.menu_displayscan,'Checked','on')
set(h.push_displayscan,'Value',1)

h.roitoggle = 0;
h.roitoggle_curve = 0;
h.dosetoggle = 0;
h.textoggle = 0;

set(h.drop_preset,'String',h.wl_presets(:,1))
h.wl_current = 'Lung';
ind = strcmpi(h.wl_current,h.wl_presets);

h.window = h.wl_presets{ind,2};
h.level = h.wl_presets{ind,3};

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

h.main_z = round(h.entry.image_zdim/2);
h.main_y = round(h.entry.image_ydim/2);
h.main_x = round(h.entry.image_xdim/2);

h.minor1_z = round(h.entry.image_zdim/2);
h.minor1_y = round(h.entry.image_ydim/2);
h.minor1_x = round(h.entry.image_xdim/2);
        
h.minor2_z = round(h.entry.image_zdim/2);
h.minor2_y = round(h.entry.image_ydim/2);
h.minor2_x = round(h.entry.image_xdim/2);

axes_main_viewerX(h)
axes_minor1_viewerX(h)
axes_minor2_viewerX(h)

guidata(hObject,h)

%--------------------------------------------------------------------------
function [h] = suspend_handles(h)
%%
h.suspend = [];
for i = 1:numel(h.h_names)
    h.suspend.(h.h_names{i}) = get(h.(h.h_names{i}),'Enable');
    set(h.(h.h_names{i}),'Enable','off');
end

drawnow; pause(0.001);

%--------------------------------------------------------------------------
function restore_handles(h)
%%
for i = 1:numel(h.h_names)
    set(h.(h.h_names{i}),'Enable',h.suspend.(h.h_names{i}));
end

drawnow; pause(0.001);

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

axes_main_viewerX(h)
axes_minor1_viewerX(h)
axes_minor2_viewerX(h)

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

axes_main_viewerX(h)
axes_minor1_viewerX(h)
axes_minor2_viewerX(h)

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

axes_main_viewerX(h)
axes_minor1_viewerX(h)
axes_minor2_viewerX(h)

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

axes_main_viewerX(h)
axes_minor1_viewerX(h)
axes_minor2_viewerX(h)

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

axes_main_viewerX(h)
axes_minor1_viewerX(h)
axes_minor2_viewerX(h)

guidata(hObject,h)

%--------------------------------------------------------------------------
function slider_level_CreateFcn(hObject,eventdata,h)
%%
if isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%VIEWER DISPLAY************************************************************
%--------------------------------------------------------------------------
function figure_viewer_KeyPressFcn(hObject,eventdata,h)
%%
key = eventdata.Key;

if strcmpi(h.active,'main')
    if strcmp(key,'uparrow')
        %And we're not out of bounds
        if (strcmp(h.view_main,'a') && h.main_z < h.entry.image_zdim) 
            h.main_z = h.main_z+1;
        elseif (strcmp(h.view_main,'c') && h.main_y < h.entry.image_ydim)
            h.main_y = h.main_y+1;
        elseif (strcmp(h.view_main,'s') && h.main_x < h.entry.image_xdim)
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

    axes_main_viewerX(h)

elseif strcmpi(h.active,'minor1')
    if strcmp(key,'uparrow')
        %And we're not out of bounds
        if (strcmp(h.view_minor1,'a') && h.minor1_z < h.entry.image_zdim) 
            h.minor1_z = h.minor1_z+1;
        elseif (strcmp(h.view_minor1,'c') && h.minor1_y < h.entry.image_ydim)
            h.minor1_y = h.minor1_y+1;
        elseif (strcmp(h.view_minor1,'s') && h.minor1_x < h.entry.image_xdim)
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

    axes_minor1_viewerX(h)

 elseif strcmpi(h.active,'minor2')
    if strcmp(key,'uparrow')
        %And we're not out of bounds
        if (strcmp(h.view_minor2,'a') && h.minor2_z < h.entry.image_zdim) 
            h.minor2_z = h.minor2_z+1;
        elseif (strcmp(h.view_minor2,'c') && h.minor2_y < h.entry.image_ydim)
            h.minor2_y = h.minor2_y+1;
        elseif (strcmp(h.view_minor2,'s') && h.minor2_x < h.entry.image_xdim)
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

    axes_minor2_viewerX(h)
end

guidata(hObject,h)

%--------------------------------------------------------------------------
function figure_viewer_WindowScrollWheelFcn(hObject,eventdata,h)
%%
key = eventdata.VerticalScrollCount;

if strcmpi(h.active,'main')
    if sum(key) == -1
        %And we're not out of bounds
        if (strcmp(h.view_main,'a') && h.main_z < h.entry.image_zdim) 
            h.main_z = h.main_z+1;
        elseif (strcmp(h.view_main,'c') && h.main_y < h.entry.image_ydim)
            h.main_y = h.main_y+1;
        elseif (strcmp(h.view_main,'s') && h.main_x < h.entry.image_xdim)
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

    axes_main_viewerX(h)
        
elseif strcmpi(h.active,'minor1')
    if sum(key) == -1
        %And we're not out of bounds
        if (strcmp(h.view_minor1,'a') && h.minor1_z < h.entry.image_zdim) 
            h.minor1_z = h.minor1_z+1;
        elseif (strcmp(h.view_minor1,'c') && h.minor1_y < h.entry.image_ydim)
            h.minor1_y = h.minor1_y+1;
        elseif (strcmp(h.view_minor1,'s') && h.minor1_x < h.entry.image_xdim)
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

    axes_minor1_viewerX(h)

elseif strcmpi(h.active,'minor2')
    if sum(key) == -1
        %And we're not out of bounds
        if (strcmp(h.view_minor2,'a') && h.minor2_z < h.entry.image_zdim) 
            h.minor2_z = h.minor2_z+1;
        elseif (strcmp(h.view_minor2,'c') && h.minor2_y < h.entry.image_ydim)
            h.minor2_y = h.minor2_y+1;
        elseif (strcmp(h.view_minor2,'s') && h.minor2_x < h.entry.image_xdim)
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

    axes_minor2_viewerX(h)
end

guidata(hObject,h)

%--------------------------------------------------------------------------
function figure_viewer_WindowButtonDownFcn(hObject,eventdata,h)
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
function figure_viewer_WindowButtonUpFcn(hObject,eventdata,h)
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

%MENU PUSH*****************************************************************
%--------------------------------------------------------------------------
function menu_file_Callback(hObject,eventdata,h)

%--------------------------------------------------------------------------
function menu_exit_Callback(hObject,eventdata,h)
%%
close(h.figure_viewer);

%--------------------------------------------------------------------------
function menu_view_Callback(hObject,eventdata,h)

%--------------------------------------------------------------------------
function menu_displayscan_Callback(hObject,eventdata,h)
%%
check = get(hObject,'Checked');
if strcmpi(check,'on')
    h.imgtoggle = 0;
    set(hObject,'Checked','off')
    set(h.push_displayscan,'Value',0)
else
    h.imgtoggle = 1;
    set(hObject,'Checked','on')
    set(h.push_displayscan,'Value',1)
end

axes_main_viewerX(h)
axes_minor1_viewerX(h)
axes_minor2_viewerX(h)
    
guidata(hObject,h)

%--------------------------------------------------------------------------
function push_displayscan_Callback(hObject,eventdata,h)
%%
button_state = get(hObject,'Value');
if button_state == get(hObject,'Min')
    h.imgtoggle = 0;
    set(h.menu_displayscan,'Checked','off')
    set(hObject,'Value',0)
    
elseif button_state == get(hObject,'Max')
    h.imgtoggle = 1;
    set(h.menu_displayscan,'Checked','on')
    set(hObject,'Value',1)
end

axes_main_viewerX(h)
axes_minor1_viewerX(h)
axes_minor2_viewerX(h)
    
guidata(hObject,h)

%--------------------------------------------------------------------------
function menu_displaymaskroi_Callback(hObject,eventdata,h)
%%
check = get(hObject,'Checked');
if strcmpi(check,'on')
    h.roitoggle = 0;
    set(hObject,'Checked','off')
    set(h.push_displaymaskroi,'Value',0)
else
    h.roitoggle = 1;
    set(hObject,'Checked','on')
    set(h.push_displaymaskroi,'Value',1)
end

axes_main_viewerX(h)
axes_minor1_viewerX(h)
axes_minor2_viewerX(h)

guidata(hObject,h)

%--------------------------------------------------------------------------
function push_displaymaskroi_Callback(hObject,eventdata,h)
%%
button_state = get(hObject,'Value');
if button_state == get(hObject,'Min')
    h.roitoggle = 0;
    set(h.menu_displaymaskroi,'Checked','off')
    set(hObject,'Value',0)
    
elseif button_state == get(hObject,'Max')
    h.roitoggle = 1;
    set(h.menu_displaymaskroi,'Checked','on')
    set(hObject,'Value',1)
end

axes_main_viewerX(h)
axes_minor1_viewerX(h)
axes_minor2_viewerX(h)
    
guidata(hObject,h)

%--------------------------------------------------------------------------
function menu_displaycurveroi_Callback(hObject,eventdata,h)
%%
check = get(hObject,'Checked');
if strcmpi(check,'on')
    h.roitoggle_curve = 0;
    set(hObject,'Checked','off')
    set(h.push_displaycurveroi,'Value',0)
else
    h.roitoggle_curve = 1;
    set(hObject,'Checked','on')
    set(h.push_displaycurveroi,'Value',1)
end

axes_main_viewerX(h)
axes_minor1_viewerX(h)
axes_minor2_viewerX(h)

guidata(hObject,h)

%--------------------------------------------------------------------------
function push_displaycurveroi_Callback(hObject,eventdata,h)
%%
button_state = get(hObject,'Value');
if button_state == get(hObject,'Min')
    h.roitoggle_curve = 0;
    set(h.menu_displaycurveroi,'Checked','off')
    set(hObject,'Value',0)
    
elseif button_state == get(hObject,'Max')
    h.roitoggle_curve = 1;
    set(h.menu_displaycurveroi,'Checked','on')
    set(hObject,'Value',1)
end

axes_main_viewerX(h)
axes_minor1_viewerX(h)
axes_minor2_viewerX(h)
    
guidata(hObject,h)

%--------------------------------------------------------------------------
function menu_displaydose_Callback(hObject,eventdata,h)
%%
check = get(hObject,'Checked');
if strcmpi(check,'on')
    h.dosetoggle = 0;
    set(hObject,'Checked','off')
    set(h.push_displaydose,'Value',0)
else
    h.dosetoggle = 1;
    set(hObject,'Checked','on')
    set(h.push_displaydose,'Value',1)
end

axes_main_viewerX(h)
axes_minor1_viewerX(h)
axes_minor2_viewerX(h)

guidata(hObject,h)

%--------------------------------------------------------------------------
function push_displaydose_Callback(hObject,eventdata,h)
%%
button_state = get(hObject,'Value');
if button_state == get(hObject,'Min')
    h.dosetoggle = 0;
    set(h.menu_displaydose,'Checked','off')
    set(hObject,'Value',0)
    
elseif button_state == get(hObject,'Max')
    h.dosetoggle = 1;
    set(h.menu_displaydose,'Checked','on')
    set(hObject,'Value',1)
end

axes_main_viewerX(h)
axes_minor1_viewerX(h)
axes_minor2_viewerX(h)
    
guidata(hObject,h)

%--------------------------------------------------------------------------
function menu_displaymap_Callback(hObject,eventdata,h)
%%
check = get(hObject,'Checked');
if strcmpi(check,'on')
    h.textoggle = 0;
    set(hObject,'Checked','off')
    set(h.push_displaymap,'Value',0)
else
    h.textoggle = 1;
    set(hObject,'Checked','on')
    set(h.push_displaymap,'Value',1)
end

h = map_update(h);

axes_main_viewerX(h)
axes_minor1_viewerX(h)
axes_minor2_viewerX(h)

guidata(hObject,h)

%--------------------------------------------------------------------------
function push_displaymap_Callback(hObject,eventdata,h)
%%
button_state = get(hObject,'Value');
if button_state == get(hObject,'Min')
    h.textoggle = 0;
    set(h.menu_displaymap,'Checked','off')
    set(hObject,'Value',0)
    
elseif button_state == get(hObject,'Max')
    h.textoggle = 1;
    set(h.menu_displaymap,'Checked','on')
    set(hObject,'Value',1)
end

h = map_update(h);

axes_main_viewerX(h)
axes_minor1_viewerX(h)
axes_minor2_viewerX(h)
    
guidata(hObject,h)

%--------------------------------------------------------------------------
function h = map_update(h)
%%
% if ~isempty(h.map_name) && ~strcmpi(h.map_name,h.map_current)
h = suspend_handles(h);

%%
if h.textoggle == 1
    
    map_file = fullfile(h.entry.project_patient,'mapx',h.map_currentfile);

    h.tex = [];
    h.tex.array = vector2array_mapX(map_file,h.map_currentmap,'linear');

    %Finish the cropping to get rid of the extra pad needed during map
    %calculation
    mask = load(map_file,'mask');
    mask = mask.mask;
    h.tex.array = prepCrop(h.tex.array,mask,'Pad',[0,0,0]);

    %Get the relative pixel coords of the cropped area now
    [~,~,crop_xV,crop_yV,crop_zV] = prepCrop(h.img.array,h.roi.mask,'Pad',[0,0,0]);

    %%
    h.tex.array = padarray(h.tex.array,[min(crop_yV)-1,min(crop_xV)-1,min(crop_zV)-1],nan,'pre');

    h.tex.array = padarray(h.tex.array,...
                           [size(h.img.array,1) - size(h.tex.array,1),...
                           size(h.img.array,2) - size(h.tex.array,2),...
                           size(h.img.array,3) - size(h.tex.array,3)],nan,'post');
         
    %No filtering applied for the time being...
    %filt = ones(5,5,2)/sum(sum(sum(ones(5,5,2))));
    %h.tex.array = nanconv_mapX(h.tex.array,filt,'nanout');
                       
%     [h.tex.norm] = norm_mapX(h.tex.array,[0,1]);
    [h.tex.norm] = percentile_mapX(h.tex.array);

    h.tex.norm(isnan(h.tex.norm)) = 0;
end

axes_main_viewerX(h)
axes_minor1_viewerX(h)
axes_minor2_viewerX(h)

%%
restore_handles(h)

%--------------------------------------------------------------------------
function pop_mapfile_Callback(hObject,eventdata,h)
%%
h.textoggle = 0;
set(h.menu_displaymap,'Checked','off')
set(h.push_displaymap,'Value',0)

set(h.menu_displaymap,'Enable','off')
set(h.push_displaymap,'Enable','off')

set(h.pop_mapfeature,'Visible','off')
set(h.pop_mapfeature,'Enable','off')
set(h.pop_mapfeature,'String',{' '})

contents = cellstr(get(hObject,'String'));
h.map_currentfile = contents{get(hObject,'Value')};

map_files = strrep(strrep(h.map_files,'[',''),']','');
map_currentfile = strrep(strrep(h.map_currentfile,'[',''),']','');

ind_map_entry = ~cellfun(@isempty,regexpi(map_files,map_currentfile));

h.map_currentfile = h.map_files{ind_map_entry};
h.map_currentmodule = h.map_files_module{ind_map_entry};

set(h.pop_mapfeature,'Visible','on')
set(h.pop_mapfeature,'Enable','on')

names = fieldnames(h.map_parameter.(h.map_currentmodule));
set(h.pop_mapfeature,'String',names)

h = map_update(h);

guidata(hObject,h)

%--------------------------------------------------------------------------
function pop_mapfile_CreateFcn(hObject,eventdata,h)
%%
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pop_mapfeature_Callback(hObject, eventdata, h)
%%
contents = cellstr(get(hObject,'String'));
h.map_currentmap = contents{get(hObject,'Value')};

set(h.menu_displaymap,'Enable','on')
set(h.push_displaymap,'Enable','on')

h = map_update(h);

guidata(hObject,h)

%--------------------------------------------------------------------------
function pop_mapfeature_CreateFcn(hObject, eventdata, h)
%%
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function menu_scaninfo_Callback(hObject,eventdata,h)
%%
scanInfo_setupX(h.entry)

% --------------------------------------------------------------------
function menu_doseinfo_Callback(hObject,eventdata,h)
%%
doseInfo_setupX(h.dose)

% --------------------------------------------------------------------
function menu_mapinfo_Callback(hObject,eventdata,h)
% hObject    handle to menu_mapinfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%--------------------------------------------------------------------------
function menu_help_Callback(hObject,eventdata,h)

%--------------------------------------------------------------------------
function menu_about_Callback(hObject,eventdata,h)
