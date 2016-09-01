function [stats] = location_features(varargin)
%LOCATION_FEATURES 
%   [STATS] = LOCATION_FEATURES(MASK,XV,YV,ZV)
%
%   Parameters include:
%  
%   'mask'   	Self explanatory
%
%   'xV'        (Optional)
%
%   'yV'        (Optional)
%
%   'zV'        (Optional)
%
%   Notes
%   -----
%   
%   References
%   ----------
%   
%   $SPK

%%
[mask,xV,yV,zV] = ParseInputs(varargin{:});

%%
stats = [];
stats.VoxelXBound1 = nan;
stats.VoxelXBound2 = nan;
stats.VoxelYBound1 = nan;
stats.VoxelYBound2 = nan;
stats.VoxelZBound1 = nan;
stats.VoxelZBound2 = nan;

stats.SpatialXBound1 = nan;
stats.SpatialXBound2 = nan;
stats.SpatialYBound1 = nan;
stats.SpatialYBound2 = nan;
stats.SpatialZBound1 = nan;
stats.SpatialZBound2 = nan;

stats.VoxelXCentroid = nan;
stats.VoxelYCentroid = nan;
stats.VoxelZCentroid = nan;
stats.SpatialXCentroid = nan;
stats.SpatialYCentroid = nan;
stats.SpatialZCentroid = nan;

if ~isscalar(mask)
    props = regionprops(double(mask));

    stats.VoxelXBound1 = props.BoundingBox(1);
    stats.VoxelXBound2 = props.BoundingBox(1)+props.BoundingBox(4);
    stats.VoxelYBound1 = props.BoundingBox(2);
    stats.VoxelYBound2 = props.BoundingBox(2)+props.BoundingBox(5);
    stats.VoxelZBound1 = props.BoundingBox(3);
    stats.VoxelZBound2 = props.BoundingBox(3)+props.BoundingBox(6);

    %Pad edges to account for situations when mask is at image
    %border...i.e. if mask is on the first slice, Bounding box is 0.5, not 1
    xV = [xV(1)-abs(mean(diff(xV))),xV,xV(end)+abs(mean(diff(xV)))];
    yV = [yV(1)-abs(mean(diff(yV))),yV,yV(end)+abs(mean(diff(yV)))];
    zV = [xV(1)-abs(mean(diff(zV))),zV,zV(end)+abs(mean(diff(zV)))];
    %%
    stats.SpatialXBound1 = interp1(0:numel(xV)-1,xV,stats.VoxelXBound1);
    stats.SpatialXBound2 = interp1(0:numel(xV)-1,xV,stats.VoxelXBound2);
    stats.SpatialYBound1 = interp1(0:numel(yV)-1,yV,stats.VoxelYBound1);
    stats.SpatialYBound2 = interp1(0:numel(yV)-1,yV,stats.VoxelYBound2);
    stats.SpatialZBound1 = interp1(0:numel(zV)-1,zV,stats.VoxelZBound1);
    stats.SpatialZBound2 = interp1(0:numel(zV)-1,zV,stats.VoxelZBound2);

    stats.VoxelXCentroid = props.Centroid(1);
    stats.VoxelYCentroid = props.Centroid(2);
    stats.VoxelZCentroid = props.Centroid(3);

    stats.SpatialXCentroid = interp1(0:numel(xV)-1,xV,stats.VoxelXCentroid);
    stats.SpatialYCentroid = interp1(0:numel(yV)-1,yV,stats.VoxelYCentroid);
    stats.SpatialZCentroid = interp1(0:numel(zV)-1,zV,stats.VoxelZCentroid);
end

%%
clearvars -except stats

%--------------------------------------------------------------------------
function [mask,xV,yV,zV] = ParseInputs(varargin)

if verLessThan('matlab','7.13')
    iptchecknargin(1,4,nargin,mfilename);
else
    narginchk(1,4);
end

% Check mask
mask = varargin{1};
validateattributes(mask,{'numeric','logical'},{'real','nonsparse'},mfilename,'mask',1);
if ndims(mask) > 3
  error(message('images:location_features:invalidSizeForMASK'))
end
mask = logical(mask); %force it to logical if it isn't already. Not in validate attributes because is is an issue with dynamic calls to shape_features

% Assign Defaults
xV = 1:size(mask,2);
yV = 1:size(mask,1);
zV = 1:size(mask,3);

% Parse Input Arguments
if nargin ~= 1
    xV = varargin{2};
    validateattributes(xV,{'numeric'},{'real','nonsparse','vector','size',[1,size(mask,2)]},mfilename,'XV',2);
    yV = varargin{3};
    validateattributes(yV,{'numeric'},{'real','nonsparse','vector','size',[1,size(mask,1)]},mfilename,'YV',3);
    zV = varargin{4};
    validateattributes(zV,{'numeric'},{'real','nonsparse','vector','size',[1,size(mask,3)]},mfilename,'ZV',4);
end

%%
clearvars -except mask xV yV zV
