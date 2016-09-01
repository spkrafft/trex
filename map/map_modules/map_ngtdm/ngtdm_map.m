function [map] = ngtdm_map(varargin) 
%NGTDM_MAP Create neighborhood gray tone difference matrix maps
%   MAP = NGTDM_MAP(I,X,Y,Z) analyzes a scaled 
%   version of I and computes a one-dimensional matrix for an image in
%   which the ith entry is a summaton of the differences between the gray
%   level of all pixels with gray level i and the aferage gray level of
%   their surrounding neighbors. The NGTDM and resulting features are 
%   calculated at the supplied points X,Y,Z. The output variable, MAP, is a
%   structure with a map calculated for each NGTDM feature.
%
%   NGTDMS = NGTDM_MAP(I,X,Y,Z,PARAM1,VALUE1,PARAM2,VALUE2,...)
%   
%   Parameters include:
%
%   'NumLevels'     An integer specifying the number of gray levels to use when
%                   scaling the grayscale values in I. For example, if
%                   'NumLevels' is 256, GRAYCOMAP scales the values in scanArray so
%                   they are integers between 1 and 256.  The number of gray 
%                   levels determines the size of the gray-level co-occurrence 
%                   matrix (NGTDM).
% 
%                   'NumLevels' must be an integer.
%   
%                   Default: 256
%    
%   'GrayLimits'    A two-element vector, [LOW HIGH], that specifies how the
%                   grayscale values in scanArray are linearly scaled into gray levels.
%                   Grayscale values less than or equal to LOW are scaled to 1.
%                   Grayscale values greater than or equal to HIGH are scaled 
%                   to HIGH.
%   
%                   Default: [min(scanArray(:)) max(scanArray(:))]
%
%   'Distance'      An integer specifying the pixel neighborhood. The
%                   neighborhood is equally expanded in all directions.
% 
%                   Default: 1
%  
%   'Dimension'     An integer specifying the pixel neighborhood. The
%                   neighborhood is equally expanded in all directions.
% 
%                   Default: 2D
%
%   Example
%   -------
%   [map] = ngtdm_map(I,X,Y,Z,'NumLevels', 256, 'GrayLevels',[0 4095],...
%                               'Distance',1,'Dimension','2D')
% 
%   Class Support
%   -------------             
%   I can be numeric or logical.  I must be real and nonsparse. SI is
%   a double matrix having the same size as I.  NGTDMS is an
%   'NumLevels'-by-'NumLevels'-by-P double array where P is the number of
%   offsets in OFFSET.
% 
%   Notes
%   -----
%   Skips over any values in I if it's value is NaN.
%
%   $SPK

%%
[I,X,Y,Z,nl,gl,dist,dim] = ParseInputs(varargin{:});

%% Scale I so that it contains integers between 1 and NL.
if gl(2) == gl(1)
    si = ones(size(I));
else
    slope = nl/(gl(2)-gl(1));
    intercept = 1-(slope*(gl(1)));
    si = floor(imlincomb(slope,I,intercept,'double'));
end

clear I

%Clip values if user had a value that is outside of the range, e.g.,
%double image = [0 .5 2;0 1 1]; 2 is outside of [0,1]. The order of the
%following lines matters in the event that NL = 0.
si(si > nl) = nl;
si(si < 1) = 1;

%% Preallocation
stats = ngtdm_features(1);
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
	par_si{count} = si(Y(count,1):Y(count,end),X(count,1):X(count,end),Z(count,1):Z(count,end));  
end

%%
disp_count = round(num_points/25);
parfor count = 1:num_points
    if rem(count,disp_count)==0
        disp('TREX-RT>> .')
    end
    
    [ngtdm,p] = ngtdm_map_matrix(par_si{count},nl,dist,dim);  

    tempstats = [];
    stats = ngtdm_features(ngtdm,p);      
    for count_stats = 1:numel(names_stats)
        tempstats(1,end+1) = mean(stats.(names_stats{count_stats}));
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
function [ngtdm,p] = ngtdm_map_matrix(roi_I,nl,dist,dim) 
%%
%Create the filter
siz = round(repmat(2*dist+1,1,dim));
h = ones(siz);
h(ceil(numel(h)/2)) = 0;

%Determine the total number of neighboring voxels, which allows a
%modification for irregular (ie not rectangular) shape (2009 IEEE Yu)
neighbors = ones(size(roi_I));
neighbors(isnan(roi_I)) = 0;    
neighbors = imfilter(neighbors,h).*neighbors; % Multiply by neighbors to set all origianl NaN values back to zero

roi_I_nonan = roi_I;
roi_I_nonan(isnan(roi_I)) = 0;

%Calculate the average matrix
ave = imfilter(roi_I_nonan,h)./neighbors; 
ave(ave==inf) = NaN; %When dividing by neighbors, the locations of original NaNs are zeros, so the result is inf

clear neighbors siz h roi_I_nonan

%Vectorize
roi_IV = roi_I(:);
aveV = ave(:);

%Get rid of nans
bad = isnan(roi_IV) | isnan(aveV);
roi_IV(bad) = [];
aveV(bad) = [];
if length(roi_IV) ~= length(aveV)
    error('Problem with nlgdmatrix')
end

%Preallocate
ngtdm = zeros(nl,1);
p = zeros(nl,1);

for i = 1:nl
    ind = roi_IV==i;
    ngtdm(i) = sum(abs(roi_IV(ind)-aveV(ind))); 
    p(i) = sum(ind);
end

%%
clearvars -except ngtdm p  

%-----------------------------------------------------------------------------
function [I,X,Y,Z,nl,gl,dist,dim] = ParseInputs(varargin)

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
  error(message('images:ngtdm_map:invalidSizeForI'))
end   
                    
%Assign Defaults
dist = 1;
nl = 16;
gl = [min(I(:)), max(I(:))];
dim = 2;

X = [1,2,3];
Y = [1,2,3];
Z = [1,2,3];

%Parse Input Arguments
if nargin > 2
    X = varargin{2};
    Y = varargin{3};
    Z = varargin{4};    
    
    paramStrings = {'NumLevels','GrayLimits','Distance','Dimension'};
  
    for k = 5:2:nargin
        param = lower(varargin{k});
        inputStr = validatestring(param, paramStrings, mfilename, 'PARAM', k);
        idx = k + 1;  %Advance index to the VALUE portion of the input.
        if idx > nargin
          error(message('images:ngtdm_map:missingParameterValue', inputStr));        
        end
        
        switch (inputStr)
            case 'NumLevels'
                nl = varargin{idx};
                validateattributes(nl,{'logical','numeric'},{'real','integer','nonnegative','nonempty','nonsparse'},mfilename,'NL',idx);
                if numel(nl) > 1
                    error(message('images:ngtdm_map:invalidNumLevels'));
                end
                nl = double(nl); 

            case 'GrayLimits'
                gl = varargin{idx};
                % step 1: checking for classes
                validateattributes(gl,{'logical','numeric'},{},mfilename,'GL',idx);
                if isempty(gl)
                    gl = [min(I(:)) max(I(:))];
                end

                % step 2: checking for attributes
                validateattributes(gl,{'logical','numeric'},{'vector','real'},mfilename,'GL',idx);
                if numel(gl) ~= 2
                    error(message('images:ngtdm_map:invalidGrayLimitsSize'));
                end
                gl = double(gl);
   
            case 'Distance'
                dist = varargin{idx};
                validateattributes(dist,{'logical','numeric'},{'real','integer','nonnegative','nonempty','nonsparse'}, mfilename,'DISTANCE',idx);
                if numel(dist) > 1
                    error(message('images:ngtdm_map:invalidDistance'));
                end
                
            case 'Dimension'
                dim = varargin{idx};
                if isnumeric(dim)
                    if dim ~= 2 || dim ~= 3 
                    else
                        error(message('images:ngtdm_map:invalidDimension'));
                    end
                elseif strcmpi(dim,'2D') || strcmpi(dim,'3D')
                    if strcmpi(dim,'2D')
                        dim = 2;
                    elseif strcmpi(dim,'3D')
                        dim = 3;
                    end
                else
                    error(message('images:ngtdm_map:invalidDimension'));
                end
        end
    end
end

%%
clearvars -except I X Y Z nl gl dist dim
