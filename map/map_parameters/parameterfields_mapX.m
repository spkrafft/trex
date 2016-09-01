function [h] = parameterfields_mapX(varargin)
    
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
h.hist.block_size = cell(0);
h.hist.overlap = cell(0);
h.hist.shift = cell(0);
h.hist.preprocess = cell(0);
h.hist.dim = cell(0);

h.glcm = [];
h.glcm.toggle = [];
h.glcm.block_size = cell(0);
h.glcm.overlap = cell(0);
h.glcm.shift = cell(0);
h.glcm.preprocess = cell(0);
h.glcm.bd = cell(0);
h.glcm.gl = cell(0);
h.glcm.dist = cell(0);
h.glcm.dim = cell(0);
h.glcm.offset = cell(0);

h.glrlm = [];
h.glrlm.toggle = [];
h.glrlm.block_size = cell(0);
h.glrlm.overlap = cell(0);
h.glrlm.shift = cell(0);
h.glrlm.preprocess = cell(0);
h.glrlm.bd = cell(0);
h.glrlm.gl = cell(0);
h.glrlm.dim = cell(0);
h.glrlm.offset = cell(0);

h.ngtdm = [];
h.ngtdm.toggle = [];
h.ngtdm.block_size = cell(0);
h.ngtdm.overlap = cell(0);
h.ngtdm.shift = cell(0);
h.ngtdm.preprocess = cell(0);
h.ngtdm.bd = cell(0);
h.ngtdm.gl = cell(0);
h.ngtdm.dist = cell(0);
h.ngtdm.dim = cell(0);

h.laws2D = [];
h.laws2D.toggle = [];
h.laws2D.block_size = cell(0);
h.laws2D.overlap = cell(0);
h.laws2D.shift = cell(0);
h.laws2D.preprocess = cell(0);
h.laws2D.dim = cell(0);

h.lung = [];
h.lung.toggle = [];
h.lung.block_size = cell(0);
h.lung.overlap = cell(0);
h.lung.shift = cell(0);
h.lung.preprocess = cell(0);
h.lung.dim = cell(0);

h.shape = [];
h.shape.toggle = [];
h.shape.block_size = cell(0);
h.shape.overlap = cell(0);
h.shape.shift = cell(0);
h.shape.dim = cell(0);

%--------------------------------------------------------------------------
%% All of the potential parameters that are used (column vectors!)

h.param_fields = {'toggle','block_size','overlap','shift','preprocess','bd','gl','dist','dim','offset'};

h.toggle = [false; true];
h.toggle_strings = {'Off'; 'On'};

h.block_size = {'15'; '31'};

h.overlap = {'0'; '5'; '7'; '10'; '14'; '15'; '30'};

h.shift = {'0'; '5'; '10'; '15'; 'Random_2D'};

[h.preprocess_strings,~,h.preprocess] = read_preprocess;
h.preprocess = ['None'; h.preprocess];
h.preprocess_strings = ['None'; h.preprocess_strings];

h.bd = {'4'; '5'; '6'; '7'; '8'; '9'; '10'; '11'; '12'};

h.gl = {'[0 4095]'; '[min(I(:)) max(I(:))]'};

h.dist = {'1'};

h.dim = {'2D'; '3D'};

h.offset = {'[1 0 0]'; '[0 1 0]'; '[0 0 1]'; '[1 1 0]'; '[-1 1 0]'; '[0 1 1]'; '[0 1 -1]'; '[1 0 1]';...
                    '[1 0 -1]'; '[1 1 1]'; '[-1 1 1]'; '[1 1 -1]'; '[-1 1 -1]'};
                
%%
clearvars -except h
