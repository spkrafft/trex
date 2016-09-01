function varargout = writeX(varargin)
% WRITEX MATLAB code for writeX.fig
%      WRITEX, by itself, creates a new WRITEX or raises the existing
%      singleton*.
%
%      H = WRITEX returns the handle to a new WRITEX or the handle to
%      the existing singleton*.
%
%      WRITEX('CALLBACK',hObject,eventData,h,...) calls the local
%      function named CALLBACK in WRITEX.M with the given input arguments.
%
%      WRITEX('Property','Value',...) creates a new WRITEX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before writeX_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to writeX_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIh

% Edit the above text to modify the response to help writeX

% Last Modified by GUIDE v2.5 03-Nov-2014 13:46:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @writeX_OpeningFcn, ...
                   'gui_OutputFcn',  @writeX_OutputFcn, ...
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
function writeX_OpeningFcn(hObject,eventdata,h,varargin)

movegui(hObject,'center')

%Set the directory
if ~isempty(varargin)
    h.project_path = varargin{2};
else
    h.project_path = uigetdir(pwd,'Select Project Directory');
end

disp('TREX-RT>> WriteX opened')

list = dir(fullfile(h.project_path,'*.mat'));

for i = 1:numel(list)
    list_mat{i,1} = list(i).name;
end

set(h.list_data,'String',list_mat)
set(h.list_data,'Max',numel(list_mat),'Min',0);

h.clinical_file = [];

h.h_names = {'list_data',...
            'push_clinical',...
            'push_csv',...
            'push_mat'};

clearvars -except h hObject

% Choose default command line output for writeX
h.output = hObject;

% Update h structure
guidata(hObject, h);

% UIWAIT makes writeX wait for user response (see UIRESUME)
uiwait(h.figure_write);

%--------------------------------------------------------------------------
function figure_write_CloseRequestFcn(hObject,eventdata,h)

if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end

disp('TREX-RT>> WriteX closed');

clear

%--------------------------------------------------------------------------
function varargout = writeX_OutputFcn(hObject,eventdata,h) 

varargout{1} = h;

delete(h.figure_write);

%--------------------------------------------------------------------------
function [h] = suspend_handles(h)

h.suspend = [];
for i = 1:numel(h.h_names)
    h.suspend.(h.h_names{i}) = get(h.(h.h_names{i}),'Enable');
    set(h.(h.h_names{i}),'Enable','off');
end

drawnow; pause(0.001);

%--------------------------------------------------------------------------
function restore_handles(h)

for i = 1:numel(h.h_names)
    set(h.(h.h_names{i}),'Enable',h.suspend.(h.h_names{i}));
end

drawnow; pause(0.001);

%--------------------------------------------------------------------------
function list_data_Callback(hObject,eventdata,h)

h.selected_data = cell(0);

contents = cellstr(get(hObject,'String'));
ind = get(hObject,'Value');
for i = 1:numel(ind)
    h.selected_data{end+1,1} = contents{ind(i)};
end

set(h.push_csv,'Enable','on')
set(h.push_mat,'Enable','on')

guidata(hObject,h)

%--------------------------------------------------------------------------
function list_data_CreateFcn(hObject,eventdata,h)
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function push_clinical_Callback(hObject,eventdata,h)

h.clinical_file = [];

[h.clinical_file,h.clinical_pathname] = uigetfile(pwd,'Select Clinical MAT File');

if h.clinical_file == 0
    h.clinical_file = [];
end

set(h.text_clinical,'String',['Filename: ',h.clinical_file]);

guidata(hObject,h)

%--------------------------------------------------------------------------
function push_csv_Callback(hObject,eventdata,h)

h = suspend_handles(h);

savename = inputdlg('Please Enter Savename:');
if isempty(savename)
    errordlg('Input must be a number','Error')
else
    h.savename = savename{1};
    write_data(h,'csv');
end

restore_handles(h)

%--------------------------------------------------------------------------
function push_mat_Callback(hObject,eventdata,h)

h = suspend_handles(h);

savename = inputdlg('Please Enter Savename:');
if isempty(savename)
    errordlg('Input must be a number','Error')
else
    h.savename = savename{1};
    write_data(h,'mat');
end

restore_handles(h)

%--------------------------------------------------------------------------
function write_data(h,filetype)

%%
disp('TREX-RT>> Gathering data...')
moduleRead = [];
for i = 1:numel(h.selected_data)
    disp('TREX-RT>> .')
    
    if i == 1
        %%
        moduleRead = load(fullfile(h.project_path,h.selected_data{i}));
        
        m1 = [];

        if isfield(moduleRead,'module')
            m1 = [moduleRead.module{1},'_'];
        end

        fields1 = fieldnames(moduleRead);
        for fCount = 1:numel(fields1)
            if ~isempty(regexpi(fields1{fCount},'^dvh')) ||...
                    ~isempty(regexpi(fields1{fCount},'^metric_')) ||...
                    ~isempty(regexpi(fields1{fCount},'^feature_')) ||...
                    ~isempty(regexpi(fields1{fCount},'^log_file'))||...
                    ~isempty(regexpi(fields1{fCount},'^module'))
                moduleRead.([m1,fields1{fCount}]) = moduleRead.(fields1{fCount});
                moduleRead = rmfield(moduleRead,fields1{fCount});
            end
        end
        
    else
        moduleRead2 = load(fullfile(h.project_path,h.selected_data{i}));
        moduleRead = combine_writeX(moduleRead,'patient_mrn',moduleRead2,'patient_mrn');
    end
end
disp('TREX-RT>> .')

%%
clinicalRead = [];
if ~isempty(h.clinical_file)
    clinicalRead = load(fullfile(h.clinical_pathname,h.clinical_file));
    
    if isempty(fieldnames(moduleRead)) || isempty(fieldnames(clinicalRead))
        error('here')
    else
        disp('TREX-RT>> Please select a link field')
        [link1,link2] = link_writeX(fieldnames(moduleRead),fieldnames(clinicalRead));
        drawnow; pause(0.001);
        disp('TREX-RT>> Link field selected')
    end
    
    moduleRead = combine_writeX(moduleRead,link1,clinicalRead,link2);
end

%%
if strcmpi(filetype,'mat')
    disp('TREX-RT>> Writing .mat file...')
    save(h.savename,'-struct','moduleRead')
    disp(['TREX-RT>> ',h.savename,' successfully saved!'])
    
elseif strcmpi(filetype,'csv')
    
    disp('TREX-RT>> Writing .csv file...')

    num_entries = numel(moduleRead.patient_mrn);
    fields = fieldnames(moduleRead);

    logfiles = cell(0);
    headings1 = cell(0);
    headings2 = cell(0);
    data = cell(0);

    for fCount = 1:numel(fields)
        if size(moduleRead.(fields{fCount}),1) == num_entries && size(moduleRead.(fields{fCount}),2) == 1
            headings1{1,end+1} = fields{fCount};
            headings2{1,end+1} = fields{fCount};
            
            if iscell(moduleRead.(fields{fCount}))
                data(:,end+1) = moduleRead.(fields{fCount});
            else
                data(:,end+1) = num2cell(moduleRead.(fields{fCount}));
            end
            
            if ~isempty(regexpi(fields{fCount},'module'))   
                tok = strrep(fields{fCount},'_module','');
                ind_all = ~cellfun(@isempty,regexpi(fields,tok));
                
                ind_module = ~cellfun(@isempty,regexpi(fields,fields{fCount}));
                
                tok = strrep(fields{fCount},'_module','_log_file');  
                ind_log = ~cellfun(@isempty,regexpi(fields,tok));
                
                logfiles{end+1,1} = moduleRead.(fields{ind_log});

                ind = ind_all & ~ind_module & ~ind_log;
                ind_bins = find(~cellfun(@isempty,regexpi(fields,'dvh_bins')) & ind);
                ind_mnames = find(~cellfun(@isempty,regexpi(fields,'metric_names')) & ind);
                ind_fnames = find(~cellfun(@isempty,regexpi(fields,'feature_names')) & ind);

                if sum(ind_bins) > 0
                    for bCount = 1:numel(ind_bins)
                        ind_bin = ind_bins(bCount);
                        tok = strrep(fields{ind_bin},'dvh_bins','dvh');  
                        ind_dvh = ~cellfun(@isempty,regexpi(fields,[tok,'$']));
                        tok2 = strrep(fields{ind_bin},'dvh_bins','bin');

                        for i = 1:numel(moduleRead.(fields{ind_bin}))
                            headings1{1,end+1} = tok2;
                            headings2{1,end+1} = [tok2,'_',num2str(moduleRead.(fields{ind_bin})(i))];
                        end
                        data = [data,num2cell(moduleRead.(fields{ind_dvh}))];
                    end 
                end
                %%
                if sum(ind_mnames) > 0
                    for mCount = 1:numel(ind_mnames)
                        ind_mname = ind_mnames(mCount);
                        tok = strrep(fields{ind_mname},'metric_names','metric_space');  
                        ind_metric = ~cellfun(@isempty,regexpi(fields,tok));
                        tok2 = strrep(fields{ind_mname},'metric_names','');

                        headings1 = [headings1,moduleRead.(fields{ind_mname})];
                        for i = 1:numel(moduleRead.(fields{ind_mname}))
                            headings2{1,end+1} = [tok2,num2str(i)];
                        end
                        data = [data,num2cell(moduleRead.(fields{ind_metric}))];
                    end 
                end
                
                if sum(ind_fnames) > 0
                    for fCount = 1:numel(ind_fnames)
                        ind_fname = ind_fnames(fCount);
                        tok = strrep(fields{ind_fname},'feature_names','feature_space');  
                        ind_feature = ~cellfun(@isempty,regexpi(fields,tok));
                        tok2 = strrep(fields{ind_fname},'feature_names','');

                        headings1 = [headings1,moduleRead.(fields{ind_fname})];
                        for i = 1:numel(moduleRead.(fields{ind_fname}))
                            headings2{1,end+1} = [tok2,num2str(i)];
                        end
                        data = [data,num2cell(moduleRead.(fields{ind_feature}))];
                    end 
                end
            end
        end
    end

    siz = length(headings1);
    log = cell(numel(logfiles),siz);
    log(:,1) = logfiles;
    
    if isempty(regexpi(h.savename,'.csv$'))
        h.savename = [h.savename,'.csv'];
    end

    dlmcellX(h.savename,[log; headings1; headings2; data])
    disp(['TREX-RT>> ',h.savename,' successfully saved!'])
end

clearvars

