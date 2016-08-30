function [glrlm,si,offset] = glrlm_matrix3D(varargin)
%GLRLM_MATRIX3D Create gray-level co-occurrence matrix.
%   GLRLM = GLRLM_MATRIX3D(I) analyzes a scaled version of I and determines
%   the number of consecutive, collinear pixels having the same gray level
%   value. The length of the run is the number of pixels in the run along a
%   given direction specified by 'Offset'.GRAYRLMATRIX3D accumulates the 
%   total occurrence of each such run. The output array is determined by the
%   number of gray levels used in the specified image and by the maximum
%   length of a given run.
%
%   GLRLM = GRAYRLMATRIX3D(I,PARAM1,VALUE1,PARAM2,VALUE2,...) returns one or
%   more gray-level run length matrices, depending on the values of the
%   optional parameter/value pairs. Parameter names can be abbreviated, and
%   case does not matter.
%   
%   Parameters include:
%  
%   'Offset'        A p-by-3 array of offsets specifying the direction of the 
%                   interested run. Each row in the array is a three-element 
%                   vector [X_OFFSET Y_OFFSET Z_OFFSET] that specifies the
%                   direction. Because this offset is often expressed as
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
%                   'NumLevels' is 16, GRAYRLMATRIX3D scales the values in I so
%                   they are integers between 1 and 16.
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
%  
%   [GLRLM,SI] = GRAYRLMATRIX3D(...) returns the scaled image used to calculate
%   GLRLM. The values in SI are between 1 and 'NumLevels'.
%
%   Class Support
%   -------------             
%   I can be numeric or logical.  I must be real and nonsparse. SI is
%   a double matrix having the same size as I.  GLRLM is an
%   'NumLevels'-by-'NumLevels'-by-P double array where P is the number of
%   offsets in OFFSET.
%
%   Notes
%   -----
%   GRAYRLMATRIX3D excludes pixels if the value is NaN. It
%   also replaces Inf with the value 'NumLevels' and -Inf with the value 1.
%
%   GRAYRLMATRIX3D ignores border pixels, if the corresponding neighbors
%   defined by 'Offset' fall outside the image boundaries.
%
%   $SPK

%%
[I,offset,nl,gl] = ParseInputs(varargin{:});

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

%%
numOffsets = size(offset,1);

if nl ~= 0

    %Pad to account for the break in a run at the image boundary
    padsi = padarray(si,[1 1 1]);
    padsi(isnan(padsi)) = 0;
    padsi = padsi + 1;

    %Create vectors of row and column subscripts for every pixel and its neighbor.
    [s(1),s(2),s(3)] = size(padsi);
    [r,c,z] = meshgrid(1:s(1),1:s(2),1:s(3));
    r = r(:);
    c = c(:);
    z = z(:);
    
    rl = max(s);

    %Compute GLRLM
    glrlm = zeros(nl,rl,numOffsets);

    parfor k = 1:numOffsets

        index = find(offset(k,:)<0);

        padsi2 = padsi;
        
        for i = 1:length(index)
            padsi2 = flipdim(padsi2,index(i));
        end
           
        [nR,nC,nZ] = size(padsi2);

        indRun = computeRunIndices(r,c,z,abs(offset(k,:)),nR,nC,nZ);
        glrlm(:,:,k) = computeGLRLM(indRun,padsi2,nl,rl);
    end
    
    lastcol = find(any(any(glrlm,1),3),1,'last');
    glrlm = glrlm(:,1:lastcol,:);

else
    glrlm = zeros(0,0,numOffsets);
end

%%
clearvars -except glrlm si offset

%-----------------------------------------------------------------------------
function [oneGLRLM] = computeGLRLM(indRun,padsi,nl,rl)
%% Computes GLRLM given one Offset
run = padsi(indRun);

clear indRun

oneGLRLM = zeros(nl,rl);

ind = [find(run(1:end-1)~=run(2:end)); length(run)];
len = diff([0; ind]);      % run lengths
val = run(ind);           % run values

clear run
clear ind

%Correct for the initial padding, which was done to break runs at image
%boundaries
val = val - 1;
good = find(val);
val = val(good);
len = len(good);

clear good

if ~isempty(val)    
    oneGLRLM = accumarray([val len],1,[nl rl]) + oneGLRLM; % accumulate each contribution 
end

clear val
clear len

%%
clearvars -except oneGLRLM

%-----------------------------------------------------------------------------
function [indRun] = computeRunIndices(r,c,z,offset,nR,nC,nZ)
%% Computes the appropriate indices for the run
ind = find(offset(1)*r == 1 | offset(2)*c == 1 | offset(3)*z == 1);

startr = r(ind);
startc = c(ind);
startz = z(ind);

r2 = zeros(length(r)+length(startr),1);
c2 = zeros(length(c)+length(startc),1);
z2 = zeros(length(z)+length(startz),1);

clear r
clear c
clear z

indr = 1;
indc = 1;
indz = 1;

for i = 1:length(ind)
    r2(indr) = startr(i);
    c2(indc) = startc(i);
    z2(indz) = startz(i);
    
    while r2(indr) <= nR && c2(indc) <= nC && z2(indz) <= nZ
        indr = indr+1;
        indc = indc+1;
        indz = indz+1;
    
        r2(indr) = r2(indr-1) + offset(1);
        c2(indc) = c2(indc-1) + offset(2);
        z2(indz) = z2(indz-1) + offset(3);
    end
    
    indr = indr+1;
    indc = indc+1;
    indz = indz+1;
end

outsideBounds = find(r2 > nR | c2 > nC | z2 > nZ);

r2(outsideBounds) = [];
c2(outsideBounds) = [];
z2(outsideBounds) = [];

indRun = r2 + (c2-1)*nR + (z2-1)*nR*nC;

clear r2
clear c2
clear z2

%%
clearvars -except indRun

%-----------------------------------------------------------------------------
function [I,offset,nl,gl] = ParseInputs(varargin)

if verLessThan('matlab','7.13')
    iptchecknargin(1,7,nargin,mfilename);
else
    narginchk(1,7);
end

%Check I
I = varargin{1};
validateattributes(I,{'logical','numeric'},{'real','nonsparse'},mfilename,'I',1);
I = double(I);
if ndims(I) > 3
  error(message('images:glrlm_matrix3D:invalidSizeForI'))
end
          
%Assign Defaults
if ndims(I) == 3
    offset =   [1 0 0; 0 1 0; 0 0 1; 1 1 0; -1 1 0; 0 1 1; 0 1 -1; 1 0 1; 1 0 -1; 1 1 1; -1 1 1; 1 1 -1; -1 1 -1];
else
    offset =   [1 0; 0 1; 1 1; -1 1];
end
nl = 16;
gl = [min(I(:)),max(I(:))];

%Parse Input Arguments
if nargin ~= 1
    paramStrings = {'Offset','NumLevels','GrayLimits'};
  
    for k = 2:2:nargin
        param = lower(varargin{k});
        inputStr = validatestring(param, paramStrings, mfilename, 'PARAM', k);
        idx = k + 1;  %Advance index to the VALUE portion of the input.
        if idx > nargin
          error(message('images:glrlm_matrix3D:missingParameterValue', inputStr));        
        end
        
        switch (inputStr)
            case 'Offset'
                offset = varargin{idx};
                validateattributes(offset,{'logical','numeric'},{'nonempty','integer','real'},mfilename, 'OFFSET', idx);
                if size(offset,2) ~= ndims(I)
                    error(message('images:glrlm_matrix3D:invalidOffsetSize'));
                end
                offset = double(offset);

            case 'NumLevels'
                nl = varargin{idx};
                validateattributes(nl,{'logical','numeric'},{'real','integer','nonnegative','nonempty','nonsparse'},mfilename, 'NL', idx);
                if numel(nl) > 1
                    error(message('images:glrlm_matrix3D:invalidNumLevels'));
                end
                nl = double(nl); 

            case 'GrayLimits'
                gl = varargin{idx};
                % step 1: checking for classes
                validateattributes(gl,{'logical','numeric'},{},mfilename, 'GL', idx);
                if isempty(gl)
                    gl = [min(I(:)) max(I(:))];
                end

                % step 2: checking for attributes
                validateattributes(gl,{'logical','numeric'},{'vector','real'},mfilename, 'GL', idx);
                if numel(gl) ~= 2
                    error(message('images:glrlm_matrix3D:invalidGrayLimitsSize'));
                end
                gl = double(gl);
        end
    end
end

%%
clearvars -except I offset nl gl
