function [glcm,si,offset] = glcm_matrix3D(varargin)
%GLCM_MATRIX3D Create gray-level co-occurrence matrix.
%   GLCMS = GLCM_MATRIX3D(I) analyzes pairs of horizontally adjacent pixels in 
%   a scaled version of I.  If I is a binary image, it is scaled to 2 levels. 
%   If I is an intensity image, it is scaled to 8 levels. In this case, there 
%   are 8 x 8 = 64 possible ordered combinations of values for each pixel 
%   pair. GLCM_MATRIX3D accumulates the total occurrence of each such 
%   combination, producing a 8-by-8 output array, GLCMS. The row and column 
%   subscripts in GLCMS correspond respectively to the first and second 
%   (scaled) pixel-pair values.
%
%   GLCMS = GLCM_MATRIX3D(I,PARAM1,VALUE1,PARAM2,VALUE2,...) returns one or
%   more gray-level co-occurrence matrices, depending on the values of the
%   optional parameter/value pairs. Parameter names can be abbreviated, and
%   case does not matter.
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
%   'NumLevels'     An integer specifying the number of gray levels to use when
%                   scaling the grayscale values in I. For example, if
%                   'NumLevels' is 16, GRAYCOMATRIX3D scales the values in I so
%                   they are integers between 1 and 16.  The number of gray 
%                   levels determines the size of the gray-level co-occurrence 
%                   matrix (GLCM).
% 
%                   'NumLevels' must be an integer.
%   
%                   Default: 16 for numeric
%    
%   'GrayLimits'    A two-element vector, [LOW HIGH], that specifies how the
%                   grayscale values in I are linearly scaled into gray levels.
%                   Grayscale values less than or equal to LOW are scaled to 1.
%                   Grayscale values greater than or equal to HIGH are scaled 
%                   to HIGH.
%   
%                   Default: [min(I(:)) max(I(:))]
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
%   [GLCMS,SI] = GLCM_MATRIX3D(...) returns the scaled image used to calculate
%   GLCM. The values in SI are between 1 and 'NumLevels'.
% 
%   Class Support
%   -------------             
%   I can be numeric or logical.  I must be real and nonsparse. SI is
%   a double matrix having the same size as I.  GLCMS is an
%   'NumLevels'-by-'NumLevels'-by-P double array where P is the number of
%   offsets in OFFSET.
% 
%   Notes
%   -----
%   Another name for a gray-level co-occurrence matrix is a gray-level
%   spatial dependence matrix.
% 
%   GLCM_MATRIX3D ignores pixels pairs if either of their values is NaN. It
%   also replaces Inf with the value 'NumLevels' and -Inf with the value 1.
% 
%   GLCM_MATRIX3D ignores border pixels, if the corresponding neighbors
%   defined by 'Offset' fall outside the image boundaries.
% 
%   Adapted from the MATLAB graycomatrix code but generalized to 3 dimensions
% 
%   $SPK

%%
[I,offset,nl,gl,sym] = ParseInputs(varargin{:});

%% Scale I so that it contains integers between 1 and NL.
if gl(2) == gl(1)
    si = ones(size(I));
else
    slope = nl/(gl(2)-gl(1));
    intercept = 1-(slope*(gl(1)));
    si = floor(imlincomb(slope,I,intercept,'double'));
    
%     si=floor((nl-1)/gl(2)*double(I))+1; %Lukes mapping
end

clear I

%Clip values if user had a value that is outside of the range, e.g.,
%double image = [0 .5 2;0 1 1]; 2 is outside of [0,1]. The order of the
%following lines matters in the event that NL = 0.
si(si > nl) = nl;
si(si < 1) = 1;

%%
numOffsets = size(offset,1);

if nl ~= 0
    %Create vectors of row and column subscripts for every pixel and its neighbor.
    [s(1),s(2),s(3)] = size(si);
    [r,c,z] = meshgrid(1:s(1),1:s(2),1:s(3));
    r = r(:);
    c = c(:);
    z = z(:);

    %Compute GLCMS
    glcm = zeros(nl,nl,numOffsets);
    
    parfor k = 1:numOffsets
        glcm(:,:,k) = computeGLCM(r,c,z,offset(k,:),si,nl);
    
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
function [oneGLCM] = computeGLCM(r,c,z,offset,si,nl)
%% Computes GLCM given one Offset
r2 = r + offset(1);
c2 = c + offset(2);
z2 = z + offset(3);

[nR,nC,nZ] = size(si);

%Determine locations where subscripts outside the image boundary
outsideBounds = find(z2 < 1 | z2 > nZ | c2 < 1 | c2 > nC | r2 < 1 | r2 > nR);

%Create vector containing si(r1,c1,z1)
index = r + (c-1)*nR + (z-1)*nR*nC;
v1 = si(index);
v1(outsideBounds) = [];

clear r
clear c
clear z

%Create vector containing si(r2,c2,z2). Not using sub2ind for performance reasons
r2(outsideBounds) = [];
c2(outsideBounds) = [];
z2(outsideBounds) = [];
index = r2 + (c2-1)*nR + (z2-1)*nR*nC;
v2 = si(index);

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
    oneGLCM = accumarray(ind, 1, [nl nl]);
end

clear ind

%%
clearvars -except oneGLCM

%-----------------------------------------------------------------------------
function [I,offset,nl,gl,sym] = ParseInputs(varargin)

if verLessThan('matlab','7.13')
    iptchecknargin(1,11,nargin,mfilename);
else
    narginchk(1,11);
end

%Check I
I = varargin{1};
validateattributes(I,{'logical','numeric'},{'real','nonsparse'},mfilename,'I',1);
I = double(I);
if ndims(I) > 3
  error(message('images:glcm_matrix3D:invalidSizeForI'))
end
          
%Assign Defaults
if ndims(I) == 3
    offset = [1 0 0; 0 1 0; 0 0 1; 1 1 0; -1 1 0; 0 1 1; 0 1 -1; 1 0 1; 1 0 -1; 1 1 1; -1 1 1; 1 1 -1; -1 1 -1];
else
    offset = [1 0; 0 1; 1 1; -1 1];
end
dist = 1;
nl = 16;
gl = [min(I(:)), max(I(:))];
sym = true;

%Parse Input Arguments
if nargin ~= 1
    paramStrings = {'Offset','NumLevels','GrayLimits','Symmetric','Distance'};
  
    for k = 2:2:nargin
        param = lower(varargin{k});
        inputStr = validatestring(param,paramStrings,mfilename,'PARAM',k);
        idx = k + 1;  %Advance index to the VALUE portion of the input.
        if idx > nargin
          error(message('images:glcm_matrix3D:missingParameterValue', inputStr));        
        end
        
        switch (inputStr)
            case 'Offset'
                offset = varargin{idx};
                validateattributes(offset,{'logical','numeric'},{'nonempty','integer','real'},mfilename,'OFFSET',idx);
                offset = double(offset);

            case 'NumLevels'
                nl = varargin{idx};
                validateattributes(nl,{'logical','numeric'},{'real','integer','nonnegative','nonempty','nonsparse'},mfilename,'NL',idx);
                if numel(nl) > 1
                    error(message('images:glcm_matrix3D:invalidNumLevels'));
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
                    error(message('images:glcm_matrix3D:invalidGrayLimitsSize'));
                end
                gl = double(gl);

            case 'Symmetric'
                sym = varargin{idx};
                validateattributes(sym,{'logical'}, {'scalar'}, mfilename,'SYMMETRIC',idx);
                   
            case 'Distance'
                dist = varargin{idx};
                validateattributes(dist,{'logical','numeric'},{'real','integer','nonnegative','nonempty','nonsparse'}, mfilename,'DISTANCE',idx);
                if numel(dist) > 1
                    error(message('images:glcm_matrix3D:invalidDistance'));
                end
        end
    end
end

offset = dist*offset;

%%
clearvars -except I offset nl gl sym
