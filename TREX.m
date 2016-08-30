function varargout = TREX(varargin)
% TREX MATLAB code for TREX.fig
%      TREX, by itself, creates a new TREX or raises the existing
%      singleton*.
%
%      H = TREX returns the handle to a new TREX or the handle to
%      the existing singleton*.
%
%      TREX('CALLBACK',hObject,eventData,h,...) calls the local
%      function named CALLBACK in TREX.M with the given input arguments.
%
%      TREX('Property','Value',...) creates a new TREX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TREX_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TREX_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIh

% Edit the above text to modify the response to help TREX

% Last Modified by GUIDE v2.5 16-Mar-2015 16:50:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TREX_OpeningFcn, ...
                   'gui_OutputFcn',  @TREX_OutputFcn, ...
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
function TREX_OpeningFcn(hObject,eventdata,h,varargin)
%%
movegui(hObject,'center')

mainDir = fileparts(which('TREX'));
fname = 'TREX icon.png';
icon = fullfile(mainDir,fname);

I = imread(icon,'BackgroundColor',get(hObject,'Color'));

% fname = 'TREX Title.png';
% title = fullfile(mainDir,fname);
% 
% I2 = imread(title);

pos = get(h.axes1,'Position');

imshow(I,'Parent',h.axes1,'XData',[0 pos(3)],'YData',[0 pos(4)])
% imshow(I2,'Parent',h.axes2)

%%
configDir = fileparts(which('config.trex'));
if isempty(configDir)
    create_configX(mainDir)
end

%%
disp('TREX-RT>> TREX-RT launched!');

h.setup_module = [];

% Choose default command line output for TREX
h.output = hObject;

%%
clearvars -except h hObject

% Update h structure
guidata(hObject,h)

% UIWAIT makes TREX wait for user response (see UIRESUME)
uiwait(h.figure_start);

%--------------------------------------------------------------------------
function varargout = TREX_OutputFcn(hObject,eventdata,h) 
%%
varargout{1} = h;

delete(h.figure_start);

%--------------------------------------------------------------------------
function figure_start_CloseRequestFcn(hObject,eventdata,h)
%%
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end

disp('TREX-RT>> TREX-RT closed');

%%
clear

%--------------------------------------------------------------------------
function drop_setupX_CreateFcn(hObject,eventdata,h)
%%
if ispc && isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function push_projects_Callback(hObject,eventdata,h)
%%
set(h.push_dose,'Enable','off')
set(h.push_texture,'Enable','off')
set(h.push_map,'Enable','off')

h.project_path = projectX;

if ~isempty(h.project_path)
    [~,name] = fileparts(h.project_path);
    set(h.text_current,'String',['Current Project: ',name])
end

if ~isempty(h.project_path)
    set(h.push_dose,'Enable','on')
    set(h.push_texture,'Enable','on')
    set(h.push_map,'Enable','on')
end

guidata(hObject,h)

%--------------------------------------------------------------------------
function push_dose_Callback(hObject,eventdata,h)
%%
doseX(1,h.project_path,'notify','off','extract');

%--------------------------------------------------------------------------
function push_texture_Callback(hObject,eventdata,h)
%%
textureX(1,h.project_path,'notify','off','extract');

%--------------------------------------------------------------------------
function push_map_Callback(hObject,eventdata,h)
%%
mapX(1,h.project_path,'notify','off','extract');

%--------------------------------------------------------------------------
function figure_start_WindowButtonDownFcn(hObject,eventdata,h)
%%
mainpos = get(h.axes1,'Position');
mainx = [mainpos(1) mainpos(1)+mainpos(3)];
mainy = [mainpos(2) mainpos(2)+mainpos(4)];

pt = get(hObject,'currentpoint');
x = pt(1);
y = pt(2);

if x > mainx(1) && x < mainx(2) && y > mainy(1) && y < mainy(2)
    web('http://www.qwantz.com','-browser')
end

%%
clear
