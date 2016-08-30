function [J,preprocess_name] = preprocess_filter_localrange(varargin)
%PREPROCESS_FILTER_LOCALRANGE 
%   [IMG,PREPROCESS_NAME] = PREPROCESS_FILTER_LOCALRANGE(IMG,NHOOD)
%
%   Parameters include:
%  
%   'img'   	Self explanatory
%
%   'nhood'     (Optional) A scalar value the indicates the size of the
%               neighborhood
%            	Default: 3
%
%   Notes
%   -----
% 
%   $SPK

[img,nhood] = ParseInputs(varargin{:});

img_inf = img;
img_inf(isnan(img)) = inf;

J = rangefilt(img_inf,true(nhood));
J(isinf(J)) = nan;

preprocess_name = ['Local Range Filter (',num2str(nhood),')'];

%%
clearvars -except J preprocess_name

%--------------------------------------------------------------------------
function [img,nhood] = ParseInputs(varargin)

if verLessThan('matlab', '7.13')
    iptchecknargin(1,2,nargin,mfilename);
else
    narginchk(1,2);
end

% Check scanArray
img = varargin{1};
validateattributes(img,{'numeric'},{'real','nonsparse'},mfilename,'I',1);
if ndims(img) > 3
  error(message('images:preprocess:invalidSizeForI'))
end

% Assign Defaults
nhood = 3;

% Parse Input Arguments
if nargin ~= 1
    nhood = varargin{2};
    validateattributes(nhood,{'numeric'},{'scalar','real'},mfilename, 'nhood', 2);
end

clearvars -except img nhood
