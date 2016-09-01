function [h] = parameterfields_doseX(varargin)

project_path = [];

if nargin == 1
    h = varargin{1};
elseif nargin == 2
    h = varargin{1};
    project_path = varargin{2};
else
    h = [];
    h.profile = cell(0);
end

h.module_names = {'dvh','plan','location','spatialdvh','mapdvh'};

%--------------------------------------------------------------------------
%% These are all defined explicitly because some parameters are dependent on the module
h.dvh = [];
h.dvh.toggle = [];

h.plan = [];
h.plan.toggle = [];

h.location = [];
h.location.toggle = [];

% h.dmh = [];
% h.dmh.toggle = [];

h.spatialdvh = [];
h.spatialdvh.toggle = [];
h.spatialdvh.weight = cell(0);

h.mapdvh = [];
h.mapdvh.toggle = [];
h.mapdvh.map = cell(0);

%--------------------------------------------------------------------------
%% All of the potential parameters that are used (column vectors!)

h.param_fields = {'toggle','weight','map'};

h.toggle = [false; true];
h.toggle_strings = {'Off'; 'On'};

h.weight = {'Radial_XY'; 'Sup_Inf'; 'Ant_Post'; 'Right_Left'};

%%
h.map_modules = {'hist','glcm','glrlm','ngtdm','laws2D','lung','shape'};
h.map = cell(0);

if ~isempty(project_path)
    % Get unique map filenames
    for mCount = 1:numel(h.map_modules)
        moduleRead = read_mapX(project_path,h.map_modules{mCount},false);    
        %h.map = [h.map; unique(strrep(moduleRead.map_file, moduleRead.roi_file,''))];
        
        temp.map = unique(strrep(moduleRead.map_file, moduleRead.roi_file,''));
        
        stats = feval([h.map_modules{mCount},'_features'],1);
        featureNames = fieldnames(stats);
        
        for j = 1:numel(temp.map)
            for i = 1:numel(featureNames)
                h.map = [h.map; [temp.map{j},featureNames{i}]];
            end
        end
    end
end

%%
clearvars -except h
