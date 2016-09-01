function [map] = hist_map(varargin) 
%HIST_MAP Create histogram matrix maps
%   MAP = HIST_MAP(I,X,Y,Z) analyzes pixels in I. The HIST and resulting features are 
%   calculated at the supplied points X,Y,Z. The output variable, MAP, is a
%   structure with a map calculated for each HIST feature.
%
%   HISTS = HIST_MAP(I,X,Y,Z)
%   
%   Parameters include:
%
%   Example
%   -------
%   [map] = hist_map(I,X,Y,Z)
% 
%   Class Support
%   -------------             
%   I can be numeric or logical.  I must be real and nonsparse.
% 
%   Notes
%   -----
%
%   $SPK

%%
[I,X,Y,Z] = ParseInputs(varargin{:});

%% Preallocation
stats = hist_features(0);
names_stats = fieldnames(stats);
all_stats = cell(0);
for count_stats = 1:numel(names_stats)
    all_stats{1,end+1} = names_stats{count_stats};
end

num_points = size(X,1);
num_col = numel(all_stats);

par_maps = nan(num_points,num_col);
par_X = nan(num_points,3);
par_Y = nan(num_points,3);
par_Z = nan(num_points,3);

par_si = cell(num_points,1);
for count = 1:num_points
	par_si{count} = I(Y(count,1):Y(count,end),X(count,1):X(count,end),Z(count,1):Z(count,end));  
end

%%
disp_count = round(num_points/25);
for count = 1:num_points
    if rem(count,disp_count)==0
        disp('TREX-RT>> .')
    end
    
    tempstats = [];
    stats = hist_features(par_si{count});      
    for count_stats = 1:numel(names_stats)
        tempstats(1,end+1) = stats.(names_stats{count_stats});
    end

    par_maps(count,:) = tempstats;

    par_X(count,:) = X(count,:);
    par_Y(count,:) = Y(count,:);
    par_Z(count,:) = Z(count,:);
end

map = [];
map.all_stats = all_stats;
map.par_maps = single(par_maps);
map.X = single(par_X);
map.Y = single(par_Y);
map.Z = single(par_Z);

%%
clearvars -except map

%-----------------------------------------------------------------------------
function [I,X,Y,Z] = ParseInputs(varargin)

if verLessThan('matlab', '7.13')
    iptchecknargin(1,15,nargin,mfilename);
else
    narginchk(1,15);
end

%Check scanArray
I = varargin{1};
validateattributes(I,{'numeric'},{'real','nonsparse'},mfilename,'I',1);
I = double(I);
if ndims(I) > 3
  error(message('images:hist_map:invalidSizeForI'))
end   
                    
%Assign Defaults
X = [1,2,3];
Y = [1,2,3];
Z = [1,2,3];

if nargin > 2
    X = varargin{2};
    Y = varargin{3};
    Z = varargin{4};   
end

%%
clearvars -except I X Y Z
