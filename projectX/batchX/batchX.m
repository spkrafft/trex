function varargout = batchX(varargin)
% BATCHX MATLAB code for batchX.fig
%      BATCHX, by itself, creates a new BATCHX or raises the existing
%      singleton*.
%
%      H = BATCHX returns the handle to a new BATCHX or the handle to
%      the existing singleton*.
%
%      BATCHX('CALLBACK',hObject,eventData,h,...) calls the local
%      function named CALLBACK in BATCHX.M with the given input arguments.
%
%      BATCHX('Property','Value',...) creates a new BATCHX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before batchX_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to batchX_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIh

% Edit the above text to modify the response to help batchX

% Last Modified by GUIDE v2.5 16-Mar-2015 16:09:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @batchX_OpeningFcn, ...
                   'gui_OutputFcn',  @batchX_OutputFcn, ...
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
function batchX_OpeningFcn(hObject,eventdata,h,varargin)

movegui(hObject,'center')

disp('TREX-RT>> Launching BatchX!');

h.tableHeadings =  {'Completed?',       'completed';...
                    'Project Path',     'project_path';...
                    'DoseX',            'dose';...
                    'TextureX',         'texture';...
                    'MapX',             'map';...
                    'Clean Log?',       'log';...
                    'Clean Project?',	'proj';...
                    'Update Project?',	'update'};

h.batch_data.completed = cell(0);
h.batch_data.project_path = cell(0);
h.batch_data.dose = cell(0);
h.batch_data.texture = cell(0);
h.batch_data.map = cell(0);
h.batch_data.log = cell(0);
h.batch_data.proj = cell(0);
h.batch_data.update = cell(0);

h.data = cell(0,size(h.tableHeadings,1));

set(h.table_data,'Visible','on');
set(h.table_data,'ColumnName',h.tableHeadings(:,1));
col_format = cell(1,numel(h.tableHeadings(:,1)));
col_format(:) = {'char'};
set(h.table_data,'ColumnFormat',col_format);
set(h.table_data,'ColumnWidth',{75 415 50 75 50 75 100 100})
set(h.table_data,'Data',h.data);

% Choose default command line output for batchX
h.output = hObject;

% Update h structure
guidata(hObject, h);

% UIWAIT makes batchX wait for user response (see UIRESUME)
uiwait(h.figure_batch);

%--------------------------------------------------------------------------
function varargout = batchX_OutputFcn(hObject,eventdata,h) 
varargout{1} = h;

delete(h.figure_batch);

%--------------------------------------------------------------------------
function figure_batch_CloseRequestFcn(hObject,eventdata,h)

if isequal(get(hObject, 'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end

disp('TREX-RT>> BatchX closed');

clear

%--------------------------------------------------------------------------
function push_add_Callback(hObject,eventdata,h)

[project_path,work] = addjobX;

if ~isempty(project_path)
    h.batch_data.completed{end+1,1} = '';
    h.batch_data.project_path{end+1,1} = project_path;
    h.batch_data.dose{end+1,1} = work{1};
    h.batch_data.texture{end+1,1} = work{2};
    h.batch_data.map{end+1,1} = work{3};
    h.batch_data.log{end+1,1} = work{4};
    h.batch_data.proj{end+1,1} = work{5};
    h.batch_data.update{end+1,1} = work{6};

    for i = 1:size(h.tableHeadings,1)
        if i == 1 %adds a new row to the roi table data
            if iscell(h.batch_data.(h.tableHeadings{i,2}))
                h.data{size(h.data,1)+1,i} = h.batch_data.(h.tableHeadings{i,2}){end};
            else
                h.data{size(h.data,1)+1,i} = h.batch_data.(h.tableHeadings{i,2})(end);
            end
        else
            if iscell(h.batch_data.(h.tableHeadings{i,2}))
                h.data{size(h.data,1),i} = h.batch_data.(h.tableHeadings{i,2}){end};
            else
                h.data{size(h.data,1),i} = h.batch_data.(h.tableHeadings{i,2})(end);
            end
        end
    end

    set(h.table_data,'Data',h.data);

    %CENTER CELLS
        jscrollpane = findjobjX(h.table_data);
        jTable = jscrollpane.getViewport.getView;

        cellStyle = jTable.getCellStyleAt(0,0);
        cellStyle.setHorizontalAlignment(cellStyle.CENTER);

        % Table must be redrawn for the change to take affect
        jTable.repaint;

    if numel(h.batch_data.project_path) > 0
        set(h.push_start,'Enable','on')
    else
        set(h.push_start,'Enable','off')
    end
end

guidata(hObject, h);

%--------------------------------------------------------------------------
function table_data_CellSelectionCallback(hObject,eventdata,h)

if ~isempty(h.data)
    set(h.table_data,'UserData',eventdata.Indices)
    set(h.push_remove,'Enable','on') 
end

guidata(hObject,h)

%--------------------------------------------------------------------------
function push_remove_Callback(hObject,eventdata,h)

index = get(h.table_data,'UserData');

if ~isempty(index)
    index = get(h.table_data,'UserData');
    
    for i = size(index,1):-1:1
        h.data(index(i,1),:) = [];
        
        sNames = fieldnames(h.batch_data);
        for nCount = 1:numel(sNames)
            h.batch_data.(sNames{nCount})(index(i,1),:) = [];
        end
    end
    set(h.table_data,'Data',h.data); 
end

pause(0.001)

set(h.push_remove,'Enable','off')

disp('TREX-RT>> Entry removed');

if numel(h.batch_data.project_path) > 0
    set(h.push_start,'Enable','on')
else
    set(h.push_start,'Enable','off')
end
 
guidata(hObject,h)

%--------------------------------------------------------------------------
function push_start_Callback(hObject,eventdata,h)

set(h.push_add,'Enable','off')
set(h.push_remove,'Enable','off')
set(h.push_start,'Enable','off')

for i = 1:numel(h.batch_data.project_path)
    
    h.data{i,1} = 'In progress...';
    set(h.table_data,'Data',h.data);
    
    if strcmpi(h.batch_data.update{i},'Y')
        update_projectX(h.batch_data.project_path{i})
    end

    if strcmpi(h.batch_data.map{i},'Y')
        mapX(1,h.batch_data.project_path{i},'notify','on','extract','remote_start')
    end
    
    if strcmpi(h.batch_data.dose{i},'Y')
        doseX(1,h.batch_data.project_path{i},'notify','on','extract','remote_start')
    end
    
    if strcmpi(h.batch_data.texture{i},'Y')
        textureX(1,h.batch_data.project_path{i},'notify','on','extract','remote_start')
    end

    if strcmpi(h.batch_data.proj{i},'Y')
        cleanup_projectX(h.batch_data.project_path{i})
    end

    if strcmpi(h.batch_data.log{i},'Y')
        cleanup_logX(h.batch_data.project_path{i})
    end
    
    h.data{i,1} = 'DONE!';
    set(h.table_data,'Data',h.data);
end 

%--------------------------------------------------------------------------
function menu_file_Callback(hObject,eventdata,h)

%--------------------------------------------------------------------------
function menu_import_Callback(hObject,eventdata,h)

[file,path] = uigetfile;

try
    in = load(fullfile(path,file));
    h.batch_data = in.batch_data;
    h.data = in.data;
    
    set(h.table_data,'Data',h.data);

    %CENTER CELLS
        jscrollpane = findjobjX(h.table_data);
        jTable = jscrollpane.getViewport.getView;

        cellStyle = jTable.getCellStyleAt(0,0);
        cellStyle.setHorizontalAlignment(cellStyle.CENTER);

        % Table must be redrawn for the change to take affect
        jTable.repaint;

    if numel(h.batch_data.project_path) > 0
        set(h.push_start,'Enable','on')
    else
        set(h.push_start,'Enable','off')
    end

catch err
end

guidata(hObject,h)

%--------------------------------------------------------------------------
function menu_export_Callback(hObject,eventdata,h)

out.batch_data = h.batch_data;
out.data = h.data;
[file,path] = uiputfile('*.mat','Save file name','batch.mat');
save(fullfile(path,file),'-struct','out')
