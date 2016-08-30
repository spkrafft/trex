function [J,filter_name] = filter_laplacian(varargin)
%FILTER_LAPLACIAN
%   [IMG,FILTER_NAME] = FILTER_LAPLACIAN(IMG,ALPHA)
%
%   Parameters include:
%  
%   'img'           Self explanatory
%
%   'alpha'         (Optional)
%                   Default: 0.2
%
%   Notes
%   -----
% 
%   $SPK

[img,alpha] = ParseInputs(varargin{:});

h = fspecial('laplacian',alpha);
J = imfilter(img,h);

filter_name = ['Laplacian (',num2str(alpha),')'];

%%
clearvars -except J filter_name

%--------------------------------------------------------------------------
function [img,alpha] = ParseInputs(varargin)

if verLessThan('matlab', '7.13')
    iptchecknargin(1,2,nargin,mfilename);
else
    narginchk(1,2);
end

% Check img
img = varargin{1};
validateattributes(img,{'numeric'},{'real','nonsparse'},mfilename,'img',1);
if ndims(img) > 3
  error(message('images:filter:invalidSizeForIMG'))
end

% Assign Defaults
alpha = 0.2;

% Parse Input Arguments
if nargin ~= 1
    alpha = varargin{2};
end

%%
clearvars -except img alpha
