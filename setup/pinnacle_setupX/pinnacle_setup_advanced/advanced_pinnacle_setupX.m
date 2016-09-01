function varargout = advanced_pinnacle_setupX(varargin)
% ADVANCED_PINNACLE_SETUPX MATLAB code for advanced_pinnacle_setupX.fig
%      ADVANCED_PINNACLE_SETUPX, by itself, creates a new ADVANCED_PINNACLE_SETUPX or raises the existing
%      singleton*.
%
%      H = ADVANCED_PINNACLE_SETUPX returns the handle to a new ADVANCED_PINNACLE_SETUPX or the handle to
%      the existing singleton*.
%
%      ADVANCED_PINNACLE_SETUPX('CALLBACK',hObject,eventData,h,...) calls the local
%      function named CALLBACK in ADVANCED_PINNACLE_SETUPX.M with the given input arguments.
%
%      ADVANCED_PINNACLE_SETUPX('Property','Value',...) creates a new ADVANCED_PINNACLE_SETUPX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before advanced_pinnacle_setupX_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to advanced_pinnacle_setupX_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIh

% Edit the above text to modify the response to help advanced_pinnacle_setupX

% Last Modified by GUIDE v2.5 02-Feb-2016 15:36:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @advanced_pinnacle_setupX_OpeningFcn, ...
                   'gui_OutputFcn',  @advanced_pinnacle_setupX_OutputFcn, ...
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
function advanced_pinnacle_setupX_OpeningFcn(hObject,eventdata,h,varargin)
%%
disp('TREX-RT>> Opening advanced ROI window!');

h.input = varargin{1};

movegui(hObject,'center')

h.mask = [];
h.roi_name = cell(0);
h.roi_source = cell(0);
h.roi_int = cell(0);
h.roi_ext = cell(0);

h.isodose = cell(0);

h.outsidePanelPos = get(h.panel_outside,'position');
h.panelPos = get(h.panel_scroll,'position');

h.panelHeight = length(h.input.roi_namelist)*20;
h.panelPos(4) = h.panelHeight;

if h.panelPos(4) > h.outsidePanelPos(4)
    set(h.slider1,'Visible','on')
    h.panelPos(2) = h.outsidePanelPos(4) - h.panelHeight;
else
    h.panelPos(2) = h.outsidePanelPos(4) - h.panelHeight;
end

set(h.panel_scroll,'position',h.panelPos)

h.panelY = h.panelPos(2);

h.textPos = [5 h.panelPos(4)-20 170 15];
h.bgPos = [188 h.panelPos(4)-20 200 15];

for i = 1:length(h.input.roi_namelist)
    h.txt_name(i) = uicontrol('Parent',h.panel_scroll,'Style','Text',...
        'Units','pixels',...
        'Position',h.textPos,...
        'FontUnits','pixels',...
        'FontSize',12,...
        'String',h.input.roi_namelist{i},...
        'HorizontalAlignment','left',...
        'BackgroundColor',[1 1 1]);
    
    h.textPos(2) = h.textPos(2) - 20;
    
    h.bg(i) = uibuttongroup('Visible','off',...
                            'Units','pixels',...
                            'Position',h.bgPos,...
                            'BorderType','none',...
                            'Parent',h.panel_scroll);
              
    h.bgPos(2) = h.bgPos(2) - 20;          

    h.box_off(i) = uicontrol(h.bg(i),'Style','radiobutton',...
                            'Position',[0 0 25 15],...
                            'HandleVisibility','off');
    
    h.box_source(i) = uicontrol(h.bg(i),'Style','radiobutton',...
                                'Position',[50 0 25 15],...
                                'HandleVisibility','off');

    h.box_int(i) = uicontrol(h.bg(i),'Style','radiobutton',...
                            'Position',[105 0 25 15],...
                            'HandleVisibility','off');

    h.box_ext(i) = uicontrol(h.bg(i),'Style','radiobutton',...
                            'Position',[165 0 25 15],...
                            'HandleVisibility','off');
    
    % Make the uibuttongroup visible after creating child objects. 
    h.bg(i).Visible = 'on';
end

if isfield(h.input.dose,'array') && ~isempty(h.input.dose.array)
    set(h.push_isoadd,'Visible','on')
    set(h.push_isoset,'Visible','on')
end

% Choose default command line output for advanced_pinnacle_setupX
h.output = hObject;

% Update h structure
guidata(hObject,h)

% UIWAIT makes advanced_pinnacle_setupX wait for user response (see UIRESUME)
uiwait(h.figure_advanced_pinnacle);

%--------------------------------------------------------------------------
function varargout = advanced_pinnacle_setupX_OutputFcn(hObject,eventdata,h) 
%%
if ~isfield(h.input.dose,'array')
    h.input.dose.array = [];
end

varargout{1} = h.roi_name;
varargout{2} = h.roi_source;
varargout{3} = h.roi_int;
varargout{4} = h.roi_ext;
varargout{5} = h.input.dose.array;

delete(h.figure_advanced_pinnacle);

%--------------------------------------------------------------------------
function figure_advanced_pinnacle_CloseRequestFcn(hObject,eventdata,h)
%%
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
     delete(hObject);
end

disp('TREX-RT>> Advanced ROI window closed');


%SLIDER********************************************************************
%--------------------------------------------------------------------------
function slider1_Callback(hObject,eventdata,h)
%%
sliderMin = get(hObject,'Min');
sliderMax = get(hObject,'Max');
sliderPos = get(hObject,'Value')/(sliderMax-sliderMin);
panelPos = get(h.panel_scroll,'position');

panelX = panelPos(1);
panelWidth = panelPos(3);
panelHeight = panelPos(4);

set(h.panel_scroll,'position',[panelX h.panelY+(panelHeight)*(1-sliderPos) panelWidth panelHeight])

%--------------------------------------------------------------------------
function slider1_CreateFcn(hObject,eventdata,h)
%%
if isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


%ROI NAME******************************************************************
%--------------------------------------------------------------------------
function edit_name_Callback(hObject,eventdata,h)
%%
name = get(hObject,'String');

compname = regexpi(name,'([a-z])([a-z0-9_]*)([a-z0-9]*)','match');
if ~isempty(compname)
    compname = compname{:};
else
    compname = [];
end

if ~strcmp(name,compname)
    set(hObject,'String','');
    errordlg('That is an invalid name. Try something else','Error')
end

guidata(hObject,h);

%--------------------------------------------------------------------------
function edit_name_CreateFcn(hObject,eventdata,h)
%%
if ispc && isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%ADD BUTTON****************************************************************
%--------------------------------------------------------------------------
function push_add_Callback(hObject,eventdata,h)
%%
toggle = zeros(length(h.txt_name),3);
for i = 1:size(toggle,1)
    toggle(i,1) = get(h.box_source(i),'Value');
    toggle(i,2) = get(h.box_int(i),'Value');
    toggle(i,3) = get(h.box_ext(i),'Value');
end

name = get(h.edit_name,'String');

if ~isempty(name) && sum(toggle(:)) > 0 && sum(strcmp(name,[h.input.roi_namelist; h.isodose; h.roi_name])) == 0
    h.roi_name{end+1,1} = name;

    h.roi_source{end+1,1} = [];
    h.roi_int{end+1,1} = [];
    h.roi_ext{end+1,1} = [];

    for i = 1:length(h.txt_name)
        if get(h.box_source(i),'Value')
            if isempty(h.roi_source{end})
                h.roi_source{end} = get(h.txt_name(i),'String');
            else
                h.roi_source{end} = [h.roi_source{end},'/',get(h.txt_name(i),'String')];
            end
        end

        if get(h.box_int(i),'Value')
            if isempty(h.roi_int{end})
                h.roi_int{end} = get(h.txt_name(i),'String');
            else
                h.roi_int{end} = [h.roi_int{end},'/',get(h.txt_name(i),'String')];
            end
        end

        if get(h.box_ext(i),'Value')
            if isempty(h.roi_ext{end})
                h.roi_ext{end} = get(h.txt_name(i),'String');
            else
                h.roi_ext{end} = [h.roi_ext{end},'/',get(h.txt_name(i),'String')];
            end
        end
    end
    
    disp(['TREX-RT>> AdvancedROI Added: Name(',h.roi_name{end,1},...
        ') Source(',h.roi_source{end,1},') Avoid Int(',h.roi_int{end,1},...
        ') Avoid Ext(',h.roi_ext{end,1},')']);
else
    errordlg('Please enter a name for the new ROI or select the source/int/ext','Error')
end

guidata(hObject,h)


%VIEW BUTTON***************************************************************
%--------------------------------------------------------------------------
function push_view_Callback(hObject,eventdata,h)
%%
h.input.export.roi_source = [];
h.input.export.roi_int = [];
h.input.export.roi_ext = [];

for i = 1:length(h.txt_name)
    if get(h.box_source(i),'Value')
        if isempty(h.input.export.roi_source)
            h.input.export.roi_source = get(h.txt_name(i),'String');
        else
            h.input.export.roi_source = [h.input.export.roi_source,'/',get(h.txt_name(i),'String')];
        end
    end

    if get(h.box_int(i),'Value')
        if isempty(h.input.export.roi_int)
            h.input.export.roi_int = get(h.txt_name(i),'String');
        else
            h.input.export.roi_int = [h.input.export.roi_int,'/',get(h.txt_name(i),'String')];
        end
    end

    if get(h.box_ext(i),'Value')
        if isempty(h.input.export.roi_ext)
            h.input.export.roi_ext = get(h.txt_name(i),'String');
        else
            h.input.export.roi_ext = [h.input.export.roi_ext,'/',get(h.txt_name(i),'String')];
        end
    end
end

h.mask = pinnacle_roi2Mask_setupX(h.input);

h.z = round(h.input.export.image_zdim/2);

axes_mask_advanced_pinnacle_setupX(h)

disp('TREX-RT>> AdvancedROI Viewer: Mask viewer populated!')

%%
clearvars -except hObject h

guidata(hObject,h);

%--------------------------------------------------------------------------
function figure_advanced_pinnacle_KeyPressFcn(hObject,eventdata,h)
%%
key = eventdata.Key;

if strcmp(key,'uparrow')
    %And we're not out of bounds
    if (strcmp(h.input.view_main,'a') && hinput.input.main_z < h.input.export.image_zdim) 
        h.input.main_z = h.input.main_z+1;
    elseif (strcmp(h.input.view_main,'c') && h.input.main_y < h.input.export.image_ydim)
        h.input.main_y = h.input.main_y+1;
    elseif (strcmp(h.input.view_main,'s') && h.input.main_x < h.input.export.image_xdim)
        h.input.main_x = h.input.main_x+1;
    end
%If the down arrow or mouse wheel is turned
elseif strcmp(key,'downarrow')
    %And we're not out of bounds
    if (strcmp(h.input.view_main,'a') && h.input.main_z > 1) 
        h.input.main_z = h.input.main_z-1;
    elseif (strcmp(h.view_main,'c') && h.input.main_y > 1)
        h.input.main_y = h.input.main_y-1;
    elseif (strcmp(h.input.view_main,'s') && h.input.main_x > 1)
        h.input.main_x = h.input.main_x-1; 
    end
elseif strcmp(key,'a')
    h.input.view_main = 'a';
elseif strcmp(key,'s')
    h.input.view_main = 's'; 
elseif strcmp(key,'c')
    h.input.view_main = 'c';
end

axes_mask_advanced_pinnacle_setupX(h);

guidata(hObject,h)

%--------------------------------------------------------------------------
function figure_advanced_pinnacle_WindowScrollWheelFcn(hObject,eventdata,h)
%%
key = eventdata.VerticalScrollCount;

if sum(key) == -1
    %And we're not out of bounds
    if (strcmp(h.input.view_main,'a') && h.input.main_z < h.input.export.image_zdim) 
        h.input.main_z = h.input.main_z+1;
    elseif (strcmp(h.input.view_main,'c') && h.input.main_y < h.input.export.image_ydim)
        h.input.main_y = h.input.main_y+1;
    elseif (strcmp(h.input.view_main,'s') && h.input.main_x < h.input.export.image_xdim)
        h.input.main_x = h.input.main_x+1;
    end
%If the down arrow or mouse wheel is turned
elseif sum(key) == 1
    %And we're not out of bounds
    if (strcmp(h.input.view_main,'a') && h.input.main_z > 1) 
        h.input.main_z = h.input.main_z-1;
    elseif (strcmp(h.input.view_main,'c') && h.input.main_y > 1)
        h.input.main_y = h.input.main_y-1;
    elseif (strcmp(h.input.view_main,'s') && h.input.main_x > 1)
        h.input.main_x = h.input.main_x-1; 
    end
end

axes_mask_advanced_pinnacle_setupX(h);
        
guidata(hObject,h)


%ADD ISOS******************************************************************
%--------------------------------------------------------------------------
function push_isoadd_Callback(hObject,eventdata,h)
%%
prompt = {'Enter dose level (in cGy):'};
dlg_title = 'Add single isodose ROI';
num_lines = 1;
answer = inputdlg(prompt,dlg_title,num_lines);

if ~isfield(h.input.dose,'array') || isempty(h.input.dose.array)
    h.input.dose.array = interpDose_pinnacle_setupX(h.input);
end

level = str2double(answer{1});
if isnan(level) || level < 500 || level > max(h.input.dose.array(:))
    errordlg('Not a valid input','Error')
    return
end

h.isodose{end+1,1} = [num2str(level),'cGy (',h.input.export.dose_name,')'];

num = length(h.txt_name)+1;

h.outsidePanelPos = get(h.panel_outside,'position');
h.panelPos = get(h.panel_scroll,'position');

h.panelHeight = num*20;
h.panelPos(4) = h.panelHeight;

if h.panelPos(4) > h.outsidePanelPos(4)
    set(h.slider1,'Visible','on')
    h.panelPos(2) = h.outsidePanelPos(4) - h.panelHeight;
else
    h.panelPos(2) = h.outsidePanelPos(4) - h.panelHeight;
end

set(h.panel_scroll,'position',h.panelPos)

h.panelY = h.panelPos(2);

h.textPos = [5 h.panelPos(4)-20 170 15];
h.bgPos = [188 h.panelPos(4)-20 200 15];

h.txt_name(num) = uicontrol('Parent',h.panel_scroll,'Style','Text',...
                            'Units','pixels',...
                            'Position',h.textPos,...
                            'FontUnits','pixels',...
                            'FontSize',12,...
                            'String',h.isodose{end},...
                            'HorizontalAlignment','left',...
                            'BackgroundColor',[1 1 1]);

h.textPos(2) = h.textPos(2) - 20;

h.bg(num) = uibuttongroup('Visible','off',...
                          'Units','pixels',...
                          'Position',h.bgPos,...
                          'BorderType','none',...
                          'Parent',h.panel_scroll);

h.bgPos(2) = h.bgPos(2) - 20;          

h.box_off(num) = uicontrol(h.bg(num),'Style','radiobutton',...
                           'Position',[0 0 25 15],...
                           'HandleVisibility','off');

h.box_source(num) = uicontrol(h.bg(num),'Style','radiobutton',...
                              'Position',[50 0 25 15],...
                              'HandleVisibility','off');

h.box_int(num) = uicontrol(h.bg(num),'Style','radiobutton',...
                           'Position',[105 0 25 15],...
                           'HandleVisibility','off');

h.box_ext(num) = uicontrol(h.bg(num),'Style','radiobutton',...
                           'Position',[165 0 25 15],...
                           'HandleVisibility','off');

% Make the uibuttongroup visible after creating child objects. 
h.bg(num).Visible = 'on';

disp('TREX-RT>> Isodose ROI Added');

set(h.slider1,'Value',1)

%%
clearvars -except hObject h

guidata(hObject,h)

%--------------------------------------------------------------------------
function push_isoset_Callback(hObject,eventdata,h)
%%
prompt = {'Enter dose interval (in cGy):'};
dlg_title = 'Add set of isodose ROIs';
num_lines = 1;
answer = inputdlg(prompt,dlg_title,num_lines);

if ~isfield(h.input.dose,'array') || isempty(h.input.dose.array)
    h.input.dose.array = interpDose_pinnacle_setupX(h.input);
end

interval = str2double(answer{1});
if isnan(interval) || interval < 500 || interval > max(h.input.dose.array(:))
    errordlg('Not a valid input','Error')
    return
end

maxdose = max(h.input.dose.array(:));

num_iso = round(maxdose/interval);

num_tot = length(h.txt_name)+num_iso;

h.outsidePanelPos = get(h.panel_outside,'position');
h.panelPos = get(h.panel_scroll,'position');

h.panelHeight = num_tot*20;
h.panelPos(4) = h.panelHeight;

if h.panelPos(4) > h.outsidePanelPos(4)
    set(h.slider1,'Visible','on')
    h.panelPos(2) = h.outsidePanelPos(4) - h.panelHeight;
else
    h.panelPos(2) = h.outsidePanelPos(4) - h.panelHeight;
end

set(h.panel_scroll,'position',h.panelPos)

h.panelY = h.panelPos(2);

h.textPos = [5 h.panelPos(4)-20 170 15];
h.bgPos = [188 h.panelPos(4)-20 200 15];

count = 1;
for i = length(h.txt_name)+1:num_tot
    h.isodose{end+1,1} = [num2str(interval*count),'cGy (',h.input.export.dose_name,')'];

    h.txt_name(i) = uicontrol('Parent',h.panel_scroll,'Style','Text',...
                              'Units','pixels',...
                              'Position',h.textPos,...
                              'FontUnits','pixels',...
                              'FontSize',12,...
                              'String',h.isodose{end},...
                              'HorizontalAlignment','left',...
                              'BackgroundColor',[1 1 1]);

    h.textPos(2) = h.textPos(2) - 20;

    h.bg(i) = uibuttongroup('Visible','off',...
                            'Units','pixels',...
                            'Position',h.bgPos,...
                            'BorderType','none',...
                            'Parent',h.panel_scroll); 
              
    h.bgPos(2) = h.bgPos(2) - 20;          

    h.box_off(i) = uicontrol(h.bg(i),'Style','radiobutton',...
                            'Position',[0 0 25 15],...
                            'HandleVisibility','off');
    
    h.box_source(i) = uicontrol(h.bg(i),'Style','radiobutton',...
                                'Position',[50 0 25 15],...
                                'HandleVisibility','off');

    h.box_int(i) = uicontrol(h.bg(i),'Style','radiobutton',...
                             'Position',[105 0 25 15],...
                             'HandleVisibility','off');

    h.box_ext(i) = uicontrol(h.bg(i),'Style','radiobutton',...
                             'Position',[165 0 25 15],...
                             'HandleVisibility','off');
    
    % Make the uibuttongroup visible after creating child objects. 
    h.bg(i).Visible = 'on';
    
    count = count+1;
end

disp('TREX-RT>> Isodose ROI Set Added');

set(h.slider1,'Value',1)

%%
clearvars -except hObject h

guidata(hObject,h)
