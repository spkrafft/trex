function [ngtdm,p,si] = ngtdm_matrix3D(varargin)
%NGTDM_MATRIX3D Create neighborhood gray tone difference matrix.
%   [NGTDM,P] = NGTDM_MATRIX3D(I) analyzes a scaled 
%   version of I and computes a one-dimensional matrix for an image in
%   which the ith entry is a summaton of the differences between the gray
%   level of all pixels with gray level i and the aferage gray level of
%   their surrounding neighbors. 
%   
%   Parameters include:
%            
%   'NumLevels'     An integer specifying the number of gray levels to use 
%                   when scaling the grayscale values in I. For example, if
%                   'NumLevels' is 16, NGRAYLDMATRIX3D scales the values in 
%                   I so they are integers between 1 and 16.
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
%   [NGTDM,P] = NGTDM_MATRIX3D returns the scaled 
%   image used to calculate NGTDM. The values in SI are between 1 and 
%   'NumLevels'. The 2D and 3D NGTDM and P refer to the ngtdm and
%   probability of occurrence matrices of the input image after analysis
%   with 2 or 3 dimensional neighborhoods. In the case that the input image
%   is 2D, the resulting NGTDM2D/P2D and NGTDM3D/P3D are the same.
%
%   Class Support
%   -------------             
%   I can be numeric or logical.  I must be real and nonsparse. SI is
%   a double matrix having the same size as I. 
%
%   Notes
%   -----
%   Appropriate adjustment the the method has been made to account for 
%   irregular (i.e. non-square) ROIs. This is done by excluding pixels if
%   the value is NaN.
%
%   $SPK

%%
[I,nl,gl,dist,dim] = ParseInputs(varargin{:});

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
[ngtdm,p] = oneNGTDM(si,nl,dist,dim);

%%
clearvars -except ngtdm p si

%-----------------------------------------------------------------------------
function [ngtdm,p] = oneNGTDM(si,nl,dist,dim)
%Create the filter
siz = round(repmat(2*dist+1,1,dim));
h = ones(siz);
h(ceil(numel(h)/2)) = 0;

%Determine the total number of neighboring voxels, which allows a
%modification for irregular (ie not rectangular) shape (2009 IEEE Yu)
neighbors = ones(size(si));
neighbors(isnan(si)) = 0;    
neighbors = imfilter(neighbors,h).*neighbors; % Multiply by neighbors to set all origianl NaN values back to zero

si_nonan = si;
si_nonan(isnan(si)) = 0;

%Calculate the average matrix
ave = imfilter(si_nonan,h)./neighbors; 
ave(ave==inf) = NaN; %When dividing by neighbors, the locations of original NaNs are zeros, so the result is inf

clear neighbors siz h si_nonan

%Vectorize
siV = si(:);
aveV = ave(:);

%Get rid of nans
bad = isnan(siV) | isnan(aveV);
siV(bad) = [];
aveV(bad) = [];
if length(siV) ~= length(aveV)
    error('Problem with nlgdmatrix')
end

%Preallocate
ngtdm = zeros(nl,1);
p = zeros(nl,1);

for i = 1:nl
    ind = siV==i;
    ngtdm(i) = sum(abs(siV(ind)-aveV(ind))); 
    p(i) = sum(ind);
end

%%
clearvars -except ngtdm p  

%-----------------------------------------------------------------------------
function [I,nl,gl,dist,dim] = ParseInputs(varargin)

if verLessThan('matlab','7.13')
    iptchecknargin(1,9,nargin,mfilename);
else
    narginchk(1,9);
end

%Check I
I = varargin{1};
validateattributes(I,{'logical','numeric'},{'real','nonsparse'},mfilename,'I',1);
I = double(I);
if ndims(I) > 3
  error(message('images:ngtdm_matrix3D:invalidSizeForI'))
end
          
%Assign Defaults
dist = 1;
nl = 16;
gl = [min(I(:)), max(I(:))];
dim = 2;

%Parse Input Arguments
if nargin ~= 1
    paramStrings = {'NumLevels','GrayLimits','Distance','Dimension'};
  
    for k = 2:2:nargin
        param = lower(varargin{k});
        inputStr = validatestring(param, paramStrings, mfilename,'PARAM',k);
        idx = k + 1;  %Advance index to the VALUE portion of the input.
        if idx > nargin
          error(message('images:ngtdm_matrix3D:missingParameterValue', inputStr));        
        end
        
        switch (inputStr)
            case 'NumLevels'
                nl = varargin{idx};
                validateattributes(nl,{'logical','numeric'},{'real','integer','nonnegative','nonempty','nonsparse'},mfilename,'NL',idx);
                if numel(nl) > 1
                    error(message('images:ngtdm_matrix3D:invalidNumLevels'));
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
                    error(message('images:ngtdm_matrix3D:invalidGrayLimitsSize'));
                end
                gl = double(gl);
   
            case 'Distance'
                dist = varargin{idx};
                validateattributes(dist,{'logical','numeric'},{'real','integer','nonnegative','nonempty','nonsparse'}, mfilename,'DISTANCE',idx);
                if numel(dist) > 1
                    error(message('images:ngtdm_matrix3D:invalidDistance'));
                end
                
            case 'Dimension'
                dim = varargin{idx};
                if isnumeric(dim)
                    if dim ~= 2 || dim ~= 3 
                    else
                        error(message('images:ngtdm_matrix3D:invalidDimension'));
                    end
                elseif strcmpi(dim,'2D') || strcmpi(dim,'3D')
                    if strcmpi(dim,'2D')
                        dim = 2;
                    elseif strcmpi(dim,'3D')
                        dim = 3;
                    end
                else
                    error(message('images:ngrayldmatrix3D:invalidDimension'));
                end
        end
    end
end

%%
clearvars -except I nl gl dist dim
