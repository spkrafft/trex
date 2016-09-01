function varargout = subvolumes_pinnacle_setupX(varargin)
% SUBVOLUMES_PINNACLE_SETUPX MATLAB code for subvolumes_pinnacle_setupX.fig
%      SUBVOLUMES_PINNACLE_SETUPX, by itself, creates a new SUBVOLUMES_PINNACLE_SETUPX or raises the existing
%      singleton*.
%
%      H = SUBVOLUMES_PINNACLE_SETUPX returns the handle to a new SUBVOLUMES_PINNACLE_SETUPX or the handle to
%      the existing singleton*.
%
%      SUBVOLUMES_PINNACLE_SETUPX('CALLBACK',hObject,eventData,h,...) calls the local
%      function named CALLBACK in SUBVOLUMES_PINNACLE_SETUPX.M with the given input arguments.
%
%      SUBVOLUMES_PINNACLE_SETUPX('Property','Value',...) creates a new SUBVOLUMES_PINNACLE_SETUPX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before subvolumes_pinnacle_setupX_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to subvolumes_pinnacle_setupX_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIh

% Edit the above text to modify the response to help subvolumes_pinnacle_setupX

% Last Modified by GUIDE v2.5 05-Nov-2014 16:21:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @subvolumes_pinnacle_setupX_OpeningFcn, ...
                   'gui_OutputFcn',  @subvolumes_pinnacle_setupX_OutputFcn, ...
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
function subvolumes_pinnacle_setupX_OpeningFcn(hObject,eventdata,h,varargin)
%%
h.roilist = varargin{2};
set(h.drop_roilist,'String',h.roilist);

h.roi_name = cell(0);
h.roi_source = cell(0);
h.roi_int = cell(0);
h.roi_ext = cell(0);

% Choose default command line output for subvolumes_pinnacle_setupX
h.output = hObject;

% Update h structure
guidata(hObject,h)

% UIWAIT makes subvolumes_pinnacle_setupX wait for user response (see UIRESUME)
uiwait(h.figure_subvolumes);

%--------------------------------------------------------------------------
function varargout = subvolumes_pinnacle_setupX_OutputFcn(hObject,eventdata,h) 
%%
varargout{1} = h.roi_name;
varargout{2} = h.roi_source;
varargout{3} = h.roi_int;
varargout{4} = h.roi_ext;

delete(h.figure_subvolumes);

%--------------------------------------------------------------------------
function figure_subvolumes_CloseRequestFcn(hObject,eventdata,h)
%%
if isequal(get(hObject, 'waitstatus'),'waiting')
    uiresume(hObject);
else
     delete(hObject);
end
%%

disp('TREX-RT>> Subvolumes ROI window closed');

%--------------------------------------------------------------------------
function drop_roilist_Callback(hObject,eventdata,h)
%%
contents = cellstr(get(hObject,'String'));
h.roi = contents{get(hObject,'Value')};

set(h.push_add,'Enable','on')

guidata(hObject,h)

%--------------------------------------------------------------------------
function drop_roilist_CreateFcn(hObject,eventdata,h)
%%
if ispc && isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function push_add_Callback(hObject,eventdata,h)
%%
h.roi_name = cell(0);
h.roi_source = cell(0);
h.roi_int = cell(0);
h.roi_ext = cell(0);

num_boxes = 23;
for count_boxes = 1:num_boxes
    if get(h.(['checkbox',num2str(count_boxes)]),'Value')
        temp = get(h.(['checkbox',num2str(count_boxes)]),'String');
        h.roi_name{end+1,1} = [h.roi,'_',temp];
        h.roi_source{end+1,1} = [h.roi,' (Subvolume: ',temp,')'];
        h.roi_int{end+1,1} = [];
        h.roi_ext{end+1,1} = [];
    end
end

guidata(hObject,h)

close(h.figure_subvolumes);

%--------------------------------------------------------------------------
function push_cancel_Callback(hObject,eventdata,h)
%%
close(h.figure_subvolumes);

%--------------------------------------------------------------------------
function checkbox1_Callback(hObject,eventdata,h)
function checkbox2_Callback(hObject,eventdata,h)
function checkbox3_Callback(hObject,eventdata,h)
function checkbox4_Callback(hObject,eventdata,h)
function checkbox5_Callback(hObject,eventdata,h)
function checkbox6_Callback(hObject,eventdata,h)
function checkbox7_Callback(hObject,eventdata,h)
function checkbox8_Callback(hObject,eventdata,h)
function checkbox9_Callback(hObject,eventdata,h)
function checkbox10_Callback(hObject,eventdata,h)
function checkbox11_Callback(hObject,eventdata,h)
function checkbox12_Callback(hObject,eventdata,h)
function checkbox13_Callback(hObject,eventdata,h)
function checkbox14_Callback(hObject,eventdata,h)
function checkbox15_Callback(hObject,eventdata,h)
function checkbox16_Callback(hObject,eventdata,h)
function checkbox17_Callback(hObject,eventdata,h)
function checkbox18_Callback(hObject,eventdata,h)
function checkbox19_Callback(hObject,eventdata,h)
function checkbox20_Callback(hObject,eventdata,h)
function checkbox21_Callback(hObject,eventdata,h)
function checkbox22_Callback(hObject,eventdata,h)
function checkbox23_Callback(hObject,eventdata,h)
