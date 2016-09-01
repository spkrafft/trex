function [map] = glcm_map(varargin) 
%GLCM_MAP Create gray-level co-occurrence matrix maps
%   MAP = GLCM_MAP(I,X,Y,Z) analyzes pairs of horizontally adjacent 
%   pixels in a scaled version of I. The GLCM and resulting features are 
%   calculated at the supplied points X,Y,Z. The output variable, MAP, is a
%   structure with a map calculated for each GLCM feature.
%
%   GLCMS = GLCM_MAP(I,X,Y,Z,PARAM1,VALUE1,PARAM2,VALUE2,...)
%   
%   Parameters include:
%
%   'Offset'        A p-by-3 array of offsets specifying the diretion between
%                   the pixel-of-interest and its neighbor. Each row in the 
%                   array is a three-element vector [X_OFFSET Y_OFFSET Z_OFFSET]
%                   that specifies the relationship, or 'Offset', between a 
%                   pair of pixels. Because this offset is often expressed as
%                   an angle, the following table lists the offset values that 
%                   specify common angles, given the pixel distance.
%                             
%                   Angle(phi,theta)    Offset
%                   ----------------    ------
%                   (0,90)              (1,0,0)
%                   (90,90)             (0,1,0)
%                   (-,90)              (0,0,1)
%                   (45,90)             (1,1,0)
%                   (135,90)            (-1,1,0)
%                   (90,45)             (0,1,1)
%                   (90,135)            (0,1,-1)
%                   (0,45)              (1,0,1)
%                   (0,135)             (1,0,-1)
%                   (45,54.7)           (1,1,1)
%                   (135,54.7)          (-1,1,1)
%                   (45,125.3)          (1,1,-1)
%                   (135,125.3)         (-1,1,-1)
% 
%                   Default: All of the above listed offsets.
%
%   'BitDepths'     An integer specifying the bit depths to use when
%                   scaling the grayscale values in I. For example, if
%                   'BitDepths' is 8, GRAYCOMAP scales the values in scanArray so
%                   they are integers between 1 and 2^8.  The number of gray 
%                   levels determines the size of the gray-level co-occurrence 
%                   matrix (GLCM).
% 
%                   'BitDepths' can be vector of integers.
%   
%                   Default: 8
%    
%   'GrayLimits'    A two-element vector, [LOW HIGH], that specifies how the
%                   grayscale values in scanArray are linearly scaled into gray levels.
%                   Grayscale values less than or equal to LOW are scaled to 1.
%                   Grayscale values greater than or equal to HIGH are scaled 
%                   to HIGH.
%   
%                   Default: [min(scanArray(:)) max(scanArray(:))]
% 
%   'Symmetric'     A Boolean that creates a GLCM where the ordering of values 
%                   in the pixel pairs is not considered. For example, when 
%                   calculating the number of times the value 1 is adjacent 
%                   to the value 2, GRAYCOMATRIX3D counts both 1,2 and 2,1 
%                   pairings, if 'Symmetric' is set to true. When 'Symmetric'
%                   is set to false, GRAYCOMATRIX3D only counts 1,2 or 2,1, 
%                   depending on the value of 'offset'. The GLCM created in 
%                   this way is symmetric across its diagonal, and is 
%                   equivalent to the GLCM described by Haralick (1973).
% 
%                   The GLCM produced by the following syntax, 
%                   graycomatrix(I, 'offset', [0 1 0], 'Symmetric', true)
%                   is equivalent to the sum of the two GLCMs produced by
%                   these statements.
% 
%                   graycomatrix(I, 'offset', [0 1 0], 'Symmetric', false) 
%                   graycomatrix(I, 'offset', [0 -1 0], 'Symmetric', false) 
% 
%                   Default: true
%
%   'Distance'      An integer specifying the distance between pixels.
%                   Alternatively, offset can be used to define the distance,
%                   but the option here exists to use the generic (default)
%                   unit offsets and alter the distance through use of this
%                   input argument.
% 
%                   Default: 1
%
%   Example
%   -------
%   [map] = glcm_map(I,X,Y,Z,'BitDepths',8,'GrayLevels',[0 4095],...
%                            'Distance',1, 'Offset',[1 0 0])
% 
%   Class Support
%   -------------             
%   I can be numeric or logical.  I must be real and nonsparse. SI is
%   a double matrix having the same size as I.  GLCMS is an
%   2^BitDepth-by-2^BitDepth-by-P double array where P is the number of
%   offsets in OFFSET.
% 
%   Notes
%   -----
%   GRAYCOMAP skips over any values in I if it's value is NaN.
%
%   $SPK

%%
[I,X,Y,Z,offset,bd,gl,sym] = ParseInputs(varargin{:});
%%
max_bd = max(bd); %get some information about the bds...
min_bd = min(bd);

max_nl = 2^max_bd;

%% Scale I so that it contains integers between 1 and NL.
if gl(2) == gl(1)
    si = ones(size(I));
else
    slope = max_nl/(gl(2)-gl(1));
    intercept = 1-(slope*(gl(1)));
    si = floor(imlincomb(slope,I,intercept,'double'));
end

clear I

%Clip values if user had a value that is outside of the range, e.g.,
%double image = [0 .5 2;0 1 1]; 2 is outside of [0,1]. The order of the
%following lines matters in the event that NL = 0.
si(si > max_nl) = max_nl;
si(si < 1) = 1;

%% Preallocation
stats = glcm_features(0);
names_stats = fieldnames(stats);
all_stats = cell(0);
all_bd = [];
for count_bd = max_bd:-1:min_bd
    for count_stats = 1:numel(names_stats)
        all_stats{1,end+1} = names_stats{count_stats};
        all_bd(1,end+1) = count_bd;
    end
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
    
    glcm = glcm_map_matrix(par_si{count},offset,max_nl,sym);  

    if ndims(glcm) == 3
        nondir = zeros(size(glcm(:,:,1)));
        for gCount = 1:size(glcm,3)
            nondir = nondir + glcm(:,:,gCount);
        end
        glcm = nondir;
    end


    tempstats = [];
    for count_bd = max_bd:-1:min_bd
        stats = glcm_features(glcm);      
        for count_stats = 1:numel(names_stats)
            tempstats(1,end+1) = stats.(names_stats{count_stats});
        end
        glcm = glcm_halveNL(glcm); %halve the glcm if we aren't at the max
    end
    
    par_maps(count,:) = tempstats;

    par_X(count,:) = X(count,:);
    par_Y(count,:) = Y(count,:);
    par_Z(count,:) = Z(count,:);
end

map = [];
map.all_stats = all_stats;
map.all_bd = all_bd;
map.par_maps = single(par_maps);
map.X = single(par_X);
map.Y = single(par_Y);
map.Z = single(par_Z);

%%
clearvars -except map

%-----------------------------------------------------------------------------
function [glcm] = glcm_map_matrix(roi_I,offset,nl,sym) 
%%
numOffsets = size(offset,1);

if nl ~= 0
    %Create vectors of row and column subscripts for every pixel and its neighbor.
    [s(1),s(2),s(3)] = size(roi_I);
    [r,c,z] = meshgrid(1:s(1),1:s(2),1:s(3));
    r = r(:);
    c = c(:);
    z = z(:);

    %Compute GLCMS
    glcm = zeros(nl,nl,numOffsets);
    
    for k = 1:numOffsets
        glcm(:,:,k) = computeGLCM(r,c,z,offset(k,:),roi_I,nl);
    
        if sym 
            %Reflect glcm across the diagonal
            glcmTranspose = glcm(:,:,k).';
            glcm(:,:,k) = glcm(:,:,k) + glcmTranspose;
        end
    end
else
    glcm = zeros(0,0,numOffsets);
end

%%
clearvars -except glcm si offset

%-----------------------------------------------------------------------------
function oneGLCM = computeGLCM(r,c,z,offset,roi_I,nl)
%% Computes GLCM given one Offset
r2 = r + offset(1);
c2 = c + offset(2);
z2 = z + offset(3);

[nR,nC,nZ] = size(roi_I);

%Determine locations where subscripts outside the image boundary
outsideBounds = find(z2 < 1 | z2 > nZ | c2 < 1 | c2 > nC | r2 < 1 | r2 > nR);

%Create vector containing si(r1,c1,z1)
index = r + (c-1)*nR + (z-1)*nR*nC;
v1 = roi_I(index);
v1(outsideBounds) = [];

clear r
clear c
clear z

%Create vector containing si(r2,c2,z2). Not using sub2ind for performance reasons
r2(outsideBounds) = [];
c2(outsideBounds) = [];
z2(outsideBounds) = [];
index = r2 + (c2-1)*nR + (z2-1)*nR*nC;
v2 = roi_I(index);

clear r2
clear c2
clear z2
clear outsideBounds
clear index

bad = isnan(v1) | isnan(v2);
ind = [v1 v2];
ind(bad,:) = [];

clear bad
clear v1
clear v2

if isempty(ind)
    oneGLCM = zeros(nl);
else
    %Tabulate the occurrences of pixel pairs having v1 and v2.
    oneGLCM = accumarray(ind,1,[nl nl]);
end

%%
clearvars -except oneGLCM

%-----------------------------------------------------------------------------
function [I,X,Y,Z,offset,bd,gl,sym] = ParseInputs(varargin)

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
  error(message('images:glcm_map:invalidSizeForI'))
end   
                    
%Assign Defaults
offset = [1 0 0; 0 1 0; 1 1 0; -1 1 0];
bd = 8;
gl = [min(I(:)) max(I(:))];
sym = true;
dist = 1;

X = [1,2,3];
Y = [1,2,3];
Z = [1,2,3];

%Parse Input Arguments
if nargin > 2
    X = varargin{2};
    Y = varargin{3};
    Z = varargin{4};    
    
    paramStrings = {'Offset','BitDepths','GrayLimits','Symmetric','Distance'};
  
    for k = 5:2:nargin
        param = lower(varargin{k});
        inputStr = validatestring(param, paramStrings, mfilename, 'PARAM', k);
        idx = k + 1;  %Advance index to the VALUE portion of the input.
        if idx > nargin
          error(message('images:glcm_map:missingParameterValue', inputStr));        
        end
        
        switch (inputStr)
            case 'Offset'
                offset = varargin{idx};
                validateattributes(offset,{'logical','numeric'},{'nonempty','integer','real'},mfilename,'OFFSET',idx);
                offset = double(offset);
                
            case 'BitDepths'
                bd = varargin{idx};
                validateattributes(bd,{'numeric'},{'integer','positive'}, mfilename,'BD',idx);
                bd = double(bd);
                
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
                    error(message('images:glcm_map:invalidGrayLimitsSize'));
                end
                gl = double(gl);
                
            case 'Symmetric'
                sym = varargin{idx};
                validateattributes(sym,{'logical'}, {'scalar'}, mfilename,'SYMMETRIC',idx);
                   
            case 'Distance'
                dist = varargin{idx};
                validateattributes(dist,{'logical','numeric'},{'real','integer','nonnegative','nonempty','nonsparse'},mfilename,'DISTANCE',idx);
                if numel(dist) > 1
                    error(message('images:glcm_map:invalidDistance'));
                end  
        end
    end
end

offset = dist*offset;

%%
clearvars -except I X Y Z offset bd gl sym
