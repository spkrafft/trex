function [J,filter_name] = filter_gaussian(varargin)
%FILTER_GAUSSIAN
%   [IMG,FILTER_NAME] = FILTER_GAUSSIAN(IMG,HSIZE,SIGMA)
%
%   Parameters include:
%  
%   'img'           Self explanatory
%
%   'hsize'         (Optional)
%                   Default: 3
%
%   'sigma'         (Optional)
%                   Default: 0.5
%
%   Notes
%   -----
% 
%   $SPK

[img,hsize,sigma] = ParseInputs(varargin{:});

h = fspecial('gaussian',hsize,sigma);
J = imfilter(img,h);

filter_name = ['Gaussian (',num2str(hsize),'/',num2str(sigma),')'];

%%
clearvars -except J filter_name

%--------------------------------------------------------------------------
function [img,hsize,sigma] = ParseInputs(varargin)

if verLessThan('matlab', '7.13')
    iptchecknargin(1,3,nargin,mfilename);
else
    narginchk(1,3);
end

% Check img
img = varargin{1};
validateattributes(img,{'numeric'},{'real','nonsparse'},mfilename,'img',1);
if ndims(img) > 3
  error(message('images:filter:invalidSizeForIMG'))
end

% Assign Defaults
hsize = 3;
sigma = 0.5;

% Parse Input Arguments
if nargin ~= 1
    hsize = varargin{2};
    sigma = varargin{3};
end

%%
clearvars -except img hsize sigma
