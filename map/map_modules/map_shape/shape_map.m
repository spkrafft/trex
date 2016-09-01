function [map] = shape_map(varargin) 
%SHAPE_MAP Create shape specific feature matrix maps
%   MAP = SHAPE_MAP(mask,X,Y,Z) analyzes pixels in I. The SHAPE and resulting features are 
%   calculated at the supplied points X,Y,Z. The output variable, MAP, is a
%   structure with a map calculated for each SHAPE feature.
%
%   SHAPES = SHAPE_MAP(mask,X,Y,Z,xV,yV,zV)
%   
%   Parameters include:
%
%   Example
%   -------
%   [map] = shape_map(mask,X,Y,Z,xV,yV,zV)
% 
%   Class Support
%   -------------             
%   mask is logical
% 
%   Notes
%   -----
%
%   $SPK

%%
[mask,X,Y,Z,xV,yV,zV] = ParseInputs(varargin{:});

%% Preallocation
stats = shape_features(0);
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
par_xV = cell(num_points,1);
par_yV = cell(num_points,1);
par_zV = cell(num_points,1);
for count = 1:num_points
	par_si{count} = mask(Y(count,1):Y(count,end),X(count,1):X(count,end),Z(count,1):Z(count,end)); 
    par_xV{count} = xV(X(count,1):X(count,end));
    par_yV{count} = yV(Y(count,1):Y(count,end));
    par_zV{count} = zV(Z(count,1):Z(count,end));
end

%%
siz_vox = [abs(mean(diff(xV))), abs(mean(diff(yV))), abs(mean(diff(zV)))];
%%
disp_count = round(num_points/25);
for count = 1:num_points
    if rem(count,disp_count)==0
        disp('TREX-RT>> .')
    end
    
    tempstats = [];
    stats = shape_features(par_si{count},siz_vox(1), siz_vox(2), siz_vox(3));      
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
function [mask,X,Y,Z,xV,yV,zV] = ParseInputs(varargin)

if verLessThan('matlab', '7.13')
    iptchecknargin(1,15,nargin,mfilename);
else
    narginchk(1,15);
end

% Check mask
mask = varargin{1};
validateattributes(mask,{'numeric','logical'},{'real','nonsparse'},mfilename,'mask',1);
if ndims(mask) > 3
  error(message('images:shape_features:invalidSizeForMASK'))
end
mask = logical(mask); %force it to logical if it isn't already. Not in validate attributes because is is an issue with dynamic calls to shape_features 
                    
%Assign Defaults
X = [1,2,3];
Y = [1,2,3];
Z = [1,2,3];

if nargin > 2
    X = varargin{2};
    Y = varargin{3};
    Z = varargin{4};   
    
%     xV = varargin{5};
%     validateattributes(xV,{'numeric'},{'real','nonsparse'},mfilename,'XV',5);
%     yV = varargin{6};
%     validateattributes(yV,{'numeric'},{'real','nonsparse'},mfilename,'YV',6);
%     zV = varargin{7};
%     validateattributes(zV,{'numeric'},{'real','nonsparse'},mfilename,'ZV',7);
    
    xV = varargin{5};
    validateattributes(xV,{'numeric'},{'real','nonsparse'},mfilename,'XV',5);
    if numel(xV) == size(mask,2)
    elseif numel(xV) == 1
        xV = xV*(1:size(mask,2));
    else
        error('here')
    end
    
    yV = varargin{6};
    validateattributes(yV,{'numeric'},{'real','nonsparse'},mfilename,'YV',6);
    if numel(yV) == size(mask,1)
    elseif numel(yV) == 1
        yV = yV*(1:size(mask,1));
    else
        error('here')
    end
    
    zV = varargin{7};
    validateattributes(zV,{'numeric'},{'real','nonsparse'},mfilename,'ZV',7);
    if numel(zV) == size(mask,3)
    elseif numel(zV) == 1
        zV = zV*(1:size(mask,3));
    else
        error('here')
    end

end

%%
clearvars -except mask X Y Z xV yV zV
