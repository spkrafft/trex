function varargout = link_writeX(varargin)
% LINK_WRITEX MATLAB code for link_writeX.fig
%      LINK_WRITEX, by itself, creates a new LINK_WRITEX or raises the existing
%      singleton*.
%
%      H = LINK_WRITEX returns the handle to a new LINK_WRITEX or the handle to
%      the existing singleton*.
%
%      LINK_WRITEX('CALLBACK',hObject,eventData,h,...) calls the local
%      function named CALLBACK in LINK_WRITEX.M with the given input arguments.
%
%      LINK_WRITEX('Property','Value',...) creates a new LINK_WRITEX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before link_writeX_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to link_writeX_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIh

% Edit the above text to modify the response to help link_writeX

% Last Modified by GUIDE v2.5 03-Nov-2014 13:45:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @link_writeX_OpeningFcn, ...
                   'gui_OutputFcn',  @link_writeX_OutputFcn, ...
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
function link_writeX_OpeningFcn(hObject,eventdata,h,varargin)

movegui(hObject,'center')

set(h.pop_trex,'String',varargin{1});
set(h.pop_clinical,'String',varargin{2});

h.trex_fieldname = [];
h.clinical_fieldname = [];

clearvars -except h hObject

% Choose default command line output for link_writeX
h.output = hObject;

% Update h structure
guidata(hObject, h);

% UIWAIT makes link_writeX wait for user response (see UIRESUME)
uiwait(h.figure_link_write);

%--------------------------------------------------------------------------
function varargout = link_writeX_OutputFcn(hObject,eventdata,h) 

varargout{1} = h.trex_fieldname;
varargout{2} = h.clinical_fieldname;

delete(h.figure_link_write);

%--------------------------------------------------------------------------
function figure_link_write_CloseRequestFcn(hObject,eventdata,h)

if isempty(h.trex_fieldname) || isempty(h.clinical_fieldname)
    msgbox('Please select link fieldnames!','Error','error');
else
    if isequal(get(hObject,'waitstatus'),'waiting')
        uiresume(hObject);
    else
        delete(hObject);
    end
end

clear

%--------------------------------------------------------------------------
function pop_clinical_Callback(hObject,eventdata,h)

contents = cellstr(get(hObject,'String'));
h.clinical_fieldname = contents{get(hObject,'Value')};

guidata(hObject,h)

%--------------------------------------------------------------------------
function pop_clinical_CreateFcn(hObject,eventdata,h)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
function pop_trex_Callback(hObject,eventdata,h)

contents = cellstr(get(hObject,'String'));
h.trex_fieldname = contents{get(hObject,'Value')};

guidata(hObject,h)

%--------------------------------------------------------------------------
function pop_trex_CreateFcn(hObject,eventdata,h)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'),get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
