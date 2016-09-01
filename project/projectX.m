function varargout = projectX(varargin)
% PROJECTX MATLAB code for projectX.fig
%      PROJECTX, by itself, creates a new PROJECTX or raises the existing
%      singleton*.
%
%      H = PROJECTX returns the handle to a new PROJECTX or the handle to
%      the existing singleton*.
%
%      PROJECTX('CALLBACK',hObject,eventData,h,...) calls the local
%      function named CALLBACK in PROJECTX.M with the given input arguments.
%
%      PROJECTX('Property','Value',...) creates a new PROJECTX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before projectX_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to projectX_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIh

% Edit the above text to modify the response to help projectX

% Last Modified by GUIDE v2.5 17-Mar-2015 13:20:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @projectX_OpeningFcn, ...
                   'gui_OutputFcn',  @projectX_OutputFcn, ...
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
function projectX_OpeningFcn(hObject,eventdata,h,varargin)
%%
movegui(hObject,'center')

if ~isempty(varargin)
    h.default_project = varargin{1};
    h.default_directory = varargin{2};
else
    mainDir = fileparts(which('TREX'));
    configPath = fullfile(mainDir,'config.trex');
    
    fid = fopen(configPath);
    config = textscan(fid,'%s','delimiter','\n');
    config = config{1};
    fclose(fid);
    
    h.default_project = textParserX(config,'default-project');
    h.default_directory = textParserX(config,'default-directory');
end

h.selected_project = h.default_project;
h.selected_directory = h.default_directory;
set(h.push_projdir,'String',h.default_directory)

h = updateProjects(h);

% Choose default command line output for projectX
h.output = hObject;

% Update h structure
guidata(hObject,h);

% UIWAIT makes projectX wait for user response (see UIRESUME)
uiwait(h.figure_project);

%--------------------------------------------------------------------------
function varargout = projectX_OutputFcn(hObject,eventdata,h) 
%%
if isempty(h.selected_project) || strcmpi(h.selected_project,'')
    varargout{1} = [];
else
    varargout{1} = fullfile(h.selected_directory,h.selected_project);
end

delete(h.figure_project);

%--------------------------------------------------------------------------
function figure_project_CloseRequestFcn(hObject,eventdata,h)
%%
if isequal(get(hObject, 'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end

clear

%--------------------------------------------------------------------------
function push_add_Callback(hObject,eventdata,h)
%%   
choice = questdlg('Please select the type of project...',...
        'Delete Menu',...
        'Pinnacle','DICOM','Cancel','Cancel');
    
new_dir = inputdlg('Please enter the project name');
if ~isempty(new_dir)
    [s,mess,messid] = mkdir(fullfile(h.selected_directory,new_dir{1},'Log'));
     
    if s == 0 || strcmpi(mess,'Directory already exists.')
        msgbox('Directory Already Exists','Error','Error')
    else
        % Handle response
        switch choice
            case 'Pinnacle'
                pinnacle_setupX(1,fullfile(h.selected_directory,new_dir{1}));
            case 'DICOM'
                msgbox('TREX-RT>> DICOM Setup Module is not active','Error','Error')
                disp('TREX-RT>> DICOM Setup Module is not active') 
            case 'Cancel'
        end
    end
end

h = updateProjects(h);
guidata(hObject,h)

%--------------------------------------------------------------------------
function push_edit_Callback(hObject,eventdata,h)
%%
setupdate = getDate_logX(fullfile(h.selected_directory,h.selected_project),'setup');
        
if setupdate ~= 0
    try
        xroi = load(fullfile(h.selected_directory,h.selected_project,'Log',[num2str(setupdate),'_setupX.mat']));
    catch err
        error('Issue with reading setupX')
    end

    if isfield(xroi,'pinnacle') && sum(xroi.pinnacle) == length(xroi.pinnacle)
        setup_module = 'Pinnacle';
    end

    if strcmpi(setup_module,'Pinnacle')
        pinnacle_setupX(1,fullfile(h.selected_directory,h.selected_project));
    elseif strcmpi(setup_module,'DICOM')
        disp('TREX-RT>> DICOM Setup Module is not active')   
    else
        error('here')   
    end

else    
    choice = questdlg('Please select the type of project...',...
        'Delete Menu',...
        'Pinnacle','DICOM','Cancel','Cancel');
    
    % Handle response
    switch choice
        case 'Pinnacle'
            pinnacle_setupX(1,fullfile(h.selected_directory,h.selected_project));
        case 'DICOM'
            disp('TREX-RT>> DICOM Setup Module is not active') 
        case 'Cancel'
    end
end

h = updateProjects(h);
guidata(hObject,h)

%--------------------------------------------------------------------------
function push_delete_Callback(hObject,eventdata,h)
%%
choice = questdlg('Would you like to delete a project directory?',...
	'Delete Menu',...
	'Yes','Cancel','Cancel');

% Handle response
switch choice
    case 'Yes'
        choice2 = questdlg('Are you sure? This cannot be undone...',...
            'Delete Menu',...
            'Yes','Cancel','Cancel');
        switch choice2
            case 'Yes'
                rmdir(fullfile(h.selected_directory,h.selected_project),'s');
            case 'Cancel'  
        end
    case 'Cancel'
end

h = updateProjects(h);
guidata(hObject,h)

%--------------------------------------------------------------------------
function push_projdir_Callback(hObject,eventdata,h)
%%
selected_directory = uigetdir(h.default_directory);

if selected_directory ~= 0
    h.selected_directory = selected_directory;
    set(h.push_projdir,'String',h.selected_directory);

    h = updateProjects(h);
    guidata(hObject,h);
end

%--------------------------------------------------------------------------
function table_proj_CellSelectionCallback(hObject,eventdata,h)
%%
modules = {'setup',...
           'extract'};
       
dose = parameterfields_doseX([]);
tex = parameterfields_textureX([]);  
map = parameterfields_mapX([]);      

modules = [modules,strcat(dose.module_names,'_dose'),strcat(tex.module_names,'_texture'),strcat(map.module_names,'_map')];

%%
set(h.table_proj,'UserData',eventdata.Indices)
index = get(h.table_proj,'UserData');

if ~isempty(index)
    index = get(h.table_proj,'UserData');
    
    if size(index,1) == 1
        h.selected_project = h.available_projects{index(1,1)};

        
        rundata = cell(0);
        for i = 1:numel(modules)
            date = getDate_logX(fullfile(h.selected_directory,h.selected_project),modules{i});
            rundata{end+1,1} = modules{i};
            rundata{end,2} = date;
        end

        [~,ind] = sort(cell2mat(rundata(:,2)));
        rundata = rundata(ind,:);

        for i = size(rundata,1):-1:1 
            if rundata{i,2}==0
                rundata(i,:) = [];
            end
        end

        ind_setup = strcmpi(rundata(:,1),'setup');
        
        if sum(ind_setup) > 0
            try
                xroi = load(fullfile(h.selected_directory,h.selected_project,'Log',[num2str(rundata{ind_setup,2}),'_setupX.mat']),'patient_mrn');
            catch err
                error('Issue with reading setupX')
            end

            num_patients = numel(unique(xroi.patient_mrn));
            num_rois = numel(xroi.patient_mrn);

            table{1,1} = 'Setup Info:';
            table{2,1} = '   # Unique Patients:'; table{2,2} = num_patients;
            table{3,1} = '   # Unique ROIs:'; table{3,2} = num_rois;
            table{4,1} = 'Module Run Info:';
            
            for i = 1:size(rundata,1)
                table{i+4,1} = ['   ',rundata{i,1}]; table{i+4,2} = datestr(datevec(num2str(rundata{i,2}),'yyyymmddHHMMSS'));
            end
            
            set(h.table_projinfo,'Data',table)
            set(h.table_projinfo,'ColumnWidth', {185 125});
        end
       
        set(h.push_edit,'Enable','on')
        set(h.push_delete,'Enable','on')
        
        set(h.menu_migrate,'Enable','on')
        set(h.menu_copy,'Enable','on')
        set(h.menu_editproj,'Enable','on')
        set(h.menu_deleteproj,'Enable','on')
        set(h.menu_cleanupproj,'Enable','on')
        set(h.menu_cleanuplog,'Enable','on')
        set(h.menu_reformat,'Enable','on')
        set(h.menu_write,'Enable','on')
    end
end

guidata(hObject,h);

%--------------------------------------------------------------------------
function [h] = updateProjects(h)
%%
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
set(h.table_proj,'ColumnWidth',{450});
set(h.table_projinfo,'Data',[])

set(h.push_edit,'Enable','off')
set(h.push_delete,'Enable','off')

set(h.menu_migrate,'Enable','off')
set(h.menu_copy,'Enable','off')
set(h.menu_editproj,'Enable','off')
set(h.menu_deleteproj,'Enable','off')
set(h.menu_cleanupproj,'Enable','off')
set(h.menu_cleanuplog,'Enable','off')
set(h.menu_reformat,'Enable','off')
set(h.menu_write,'Enable','off')

pause(0.001); drawnow;

%--------------------------------------------------------------------------
function menu_file_Callback(hObject,eventdata,h)

%--------------------------------------------------------------------------
function menu_currdir_Callback(hObject,eventdata,h)
%%
selected_directory = uigetdir(h.default_directory);

if selected_directory ~= 0
    h.selected_directory = selected_directory;
    set(h.push_projdir,'String',h.selected_directory);
    h = updateProjects(h);
    guidata(hObject,h);
end

%--------------------------------------------------------------------------
function menu_addpinn_Callback(hObject,eventdata,h)
%%
new_dir = inputdlg('Please enter the project name');
if ~isempty(new_dir)
    [s,mess,messid] = mkdir(fullfile(h.selected_directory,new_dir{1},'Log'));

    if s == 0 || strcmpi(mess,'Directory already exists.')
        msgbox('Directory Already Exists','Error','Error')
    else
        pinnacle_setupX(1,fullfile(h.selected_directory,new_dir{1}));
    end
end

h = updateProjects(h);
guidata(hObject,h)

%--------------------------------------------------------------------------
function menu_adddicom_Callback(hObject,eventdata,h)
%%
new_dir = inputdlg('Please enter the project name');
if ~isempty(new_dir)
    [s, mess, messid] = mkdir(fullfile(h.selected_directory,new_dir{1},'Log'));

    if s==0 || strcmpi(mess,'Directory already exists.')
        msgbox('Directory Already Exists','Error','Error')
    else
        msgbox('TREX-RT>> DICOM Setup Module is not active','Error','Error')
        disp('TREX-RT>> DICOM Setup Module is not active') 
    end
end

h = updateProjects(h);
guidata(hObject,h)

%--------------------------------------------------------------------------
function menu_migrate_Callback(hObject,eventdata,h)
%%
exixting_dir = uigetdir(h.selected_directory);
if exixting_dir ~= 0
    %Get the root directory of the existing project to be added
    [root_dir, existing_project] = fileparts(exixting_dir);

    %Simple check to see if this is a TREX project
    if ~exist(fullfile(exixting_dir,'Log'),'dir')
        msgbox('This is not a valid existing TREX project!', 'Error','error');
        %Terminate if it is not
        return
    end

    %If the root directory is different than the current
    %directory...
    if ~isequal(root_dir,h.selected_directory)
        h = updateProjects(h);

        %Look for similarly named project in the current directory
        if sum(strcmpi(h.available_projects,existing_project)) > 0
            msgbox('Similarly named project already exists!', 'Error','error');
            %Terminate if it exists
            return
        else
            w = waitbar(0,'Copying Project...');

            %If there is no similarly named directory, then copy it
            copyfile(exixting_dir,fullfile(h.selected_directory,existing_project))

            close(w)

            %And then migrate
            migration_projectX(fullfile(h.selected_directory,existing_project));
        end

    %If the root directory for the existing project is the same
    %as the current directory    
    else
        %Run the migration routine
        migration_projectX(exixting_dir);
    end
end

%--------------------------------------------------------------------------
function menu_copy_Callback(hObject,eventdata,h)
%%
choice = questdlg('Would you like to copy project data?',...
    'Copy Menu',...
    'Copy','Cancel','Cancel');

% Handle response
switch choice
    case 'Copy'

        w = waitbar(0,'Copying Project...');

        now_str = datestr(now,'yyyymmddHHMMSS');

        %If there is no similarly named directory, then copy it
        copyfile(fullfile(h.selected_directory,h.selected_project),...
            fullfile(h.selected_directory,[h.selected_project,' Copy ',now_str]))

        close(w)

        %And then migrate
        migration_projectX(fullfile(h.selected_directory,[h.selected_project,' Copy ',now_str]));

    case 'Cancel'
end

h = updateProjects(h);
guidata(hObject,h)

%--------------------------------------------------------------------------
function menu_editproj_Callback(hObject,eventdata,h)
%%
setupdate = getDate_logX(fullfile(h.selected_directory,h.selected_project),'setup');

if setupdate ~= 0
    try
        xroi = load(fullfile(h.selected_directory,h.selected_project,'Log',[num2str(setupdate),'_setupX.mat']));
    catch err
        error('Issue with reading setupX')
    end

    if isfield(xroi,'pinnacle') && sum(xroi.pinnacle) == length(xroi.pinnacle)
        setup_module = 'Pinnacle';
    end

    if strcmpi(setup_module,'Pinnacle')
        pinnacle_setupX(1,fullfile(h.selected_directory,h.selected_project));
    elseif strcmpi(setup_module,'DICOM')
        disp('TREX-RT>> DICOM Setup Module is not active')   
    else
        error('here')   
    end

else    
    choice = questdlg('Please select the type of project...',...
        'Delete Menu',...
        'Pinnacle','DICOM','Cancel','Cancel');

    % Handle response
    switch choice
        case 'Pinnacle'
            pinnacle_setupX(1,fullfile(h.selected_directory,h.selected_project));
        case 'DICOM'
            disp('TREX-RT>> DICOM Setup Module is not active') 
        case 'Cancel'
    end
end

h = updateProjects(h);
guidata(hObject,h)

%--------------------------------------------------------------------------
function menu_deleteproj_Callback(hObject,eventdata,h)
%%
choice = questdlg('Would you like to delete a project directory?',...
    'Delete Menu',...
    'Yes','Cancel','Cancel');

% Handle response
switch choice
    case 'Yes'
        choice2 = questdlg('Are you sure? This cannot be undone...',...
            'Delete Menu',...
            'Yes','Cancel','Cancel');
        switch choice2
            case 'Yes'
                rmdir(fullfile(h.selected_directory,h.selected_project),'s');
            case 'Cancel'  
        end
    case 'Cancel'
end

h = updateProjects(h);
guidata(hObject,h)

%--------------------------------------------------------------------------
function menu_exit_Callback(hObject,eventdata,h)
%%
close(h.figure_project);

%--------------------------------------------------------------------------
function menu_options_Callback(hObject,eventdata,h)

%--------------------------------------------------------------------------
function menu_defaultdir_Callback(hObject,eventdata,h)
%%
selected_directory = uigetdir(h.default_directory);

if selected_directory ~= 0
    h.selected_directory = selected_directory;
    set(h.push_projdir,'String',h.selected_directory);

    mainDir = fileparts(which('TREX'));
    configPath = fullfile(mainDir,'config.trex');
    
    fid = fopen(configPath);
    config = textscan(fid,'%s','delimiter','\n');
    config = config{1};
    fclose(fid);

    config{~cellfun(@isempty, regexpi(config,'default-project'))} = ['default-project = '];
    config{~cellfun(@isempty, regexpi(config,'default-directory'))} = ['default-directory = ',h.selected_directory];

    dlmcellX(configPath,config)
    
    h = updateProjects(h);
    guidata(hObject,h);
end

%--------------------------------------------------------------------------
function menu_batch_Callback(hObject,eventdata,h)
%%
batchX

%--------------------------------------------------------------------------
function menu_cleanupproj_Callback(hObject,eventdata,h)
%%
choice = questdlg('Would you like to cleanup a project directory? This will delete all downloaded source data...',...
                  'Cleanup Menu',...
                  'Yes','Cancel','Cancel');

% Handle response
switch choice
    case 'Yes'
        choice2 = questdlg('Are you sure? This cannot be undone...',...
            'Cleanup Menu',...
            'Yes','Cancel','Cancel');
        switch choice2
            case 'Yes'
                cleanup_projectX(fullfile(h.selected_directory,h.selected_project));
            case 'Cancel'
        end
    case 'Cancel'
end

h = updateProjects(h);
guidata(hObject,h)

%--------------------------------------------------------------------------
function menu_cleanuplog_Callback(hObject,eventdata,h)
%%
cleanup_logX(fullfile(h.selected_directory,h.selected_project));
h = updateProjects(h);
guidata(hObject,h)

%--------------------------------------------------------------------------
function menu_reformat_Callback(hObject,eventdata,h)
%%
choice = questdlg('Would you like to reformat project data?',...
    'Reformat Menu',...
    'Reformat','Cancel','Cancel');
% Handle response
switch choice
    case 'Reformat'

    case 'Cancel'
end

h = updateProjects(h);
guidata(hObject,h)

%--------------------------------------------------------------------------
function menu_write_Callback(hObject,eventdata,h)
%%
writeX(1,fullfile(h.selected_directory,h.selected_project));
h = updateProjects(h);
guidata(hObject,h)

%--------------------------------------------------------------------------
function menu_help_Callback(hObject,eventdata,h)
