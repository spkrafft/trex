function [h] = parameterfields_textureX(varargin)
    
if nargin == 1
    h = varargin{1};
else
    h = [];
    h.profile = cell(0);
end

h.module_names = {'hist','glcm','glrlm','ngtdm','laws2D','lung','shape'};

%--------------------------------------------------------------------------
%% These are all defined explicitly because some parameters are dependent on the module
h.hist = [];
h.hist.toggle = [];
h.hist.preprocess = cell(0);

% h.shape = [];
% h.shape.toggle = [];

h.glcm = [];
h.glcm.toggle = [];
h.glcm.preprocess = cell(0);
h.glcm.bd = cell(0);
h.glcm.gl = cell(0);
h.glcm.dist = cell(0);
h.glcm.offset = cell(0);
h.glcm.dim = cell(0);

h.glrlm = [];
h.glrlm.toggle = [];
h.glrlm.preprocess = cell(0);
h.glrlm.bd = cell(0);
h.glrlm.gl = cell(0);
h.glrlm.offset = cell(0);
h.glrlm.dim = cell(0);

h.ngtdm = [];
h.ngtdm.toggle = [];
h.ngtdm.preprocess = cell(0);
h.ngtdm.bd = cell(0);
h.ngtdm.gl = cell(0);
h.ngtdm.dist = cell(0);
h.ngtdm.dim = cell(0);

h.laws2D = [];
h.laws2D.toggle = [];
h.laws2D.preprocess = cell(0);

% h.fractal = [];
% h.fractal.toggle = [];
% h.fractal.preprocess = cell(0);
% % h.fractal.bd = nan;
% % h.fractal.gl = cell(0);
% % h.fractal.dist = nan;
% % h.fractal.dim = cell(0);

h.lung = [];
h.lung.toggle = [];
h.lung.preprocess = cell(0);

h.shape = [];
h.shape.toggle = [];

%--------------------------------------------------------------------------
%% All of the potential parameters that are used (column vectors!)

h.param_fields = {'toggle','preprocess','bd','gl','dim','offset','dist'};

h.toggle = [false; true];
h.toggle_strings = {'Off'; 'On'};

[h.preprocess_strings,~,h.preprocess] = read_preprocess;
h.preprocess = ['None'; h.preprocess];
h.preprocess_strings = ['None'; h.preprocess_strings];

h.bd = {'4'; '5'; '6'; '7'; '8'; '9'; '10'; '11'; '12'};

h.gl = {'[0 4095]'; '[min(I(:)) max(I(:))]'};

h.offset = {'[1 0 0]'; '[0 1 0]'; '[0 0 1]'; '[1 1 0]'; '[-1 1 0]'; '[0 1 1]'; '[0 1 -1]'; '[1 0 1]';...
                    '[1 0 -1]'; '[1 1 1]'; '[-1 1 1]'; '[1 1 -1]'; '[-1 1 -1]'};
                
h.dim = {'2D'; '3D'};

h.dist = {'1'; '3'; '5'};

%%
clearvars -except h
