function [J,filter_name] = filter_ave(varargin)
%FILTER_AVE
%   [IMG,FILTER_NAME] = FILTER_AVE(IMG,HSIZE)
%
%   Parameters include:
%  
%   'img'           Self explanatory
%
%   'hsize'         (Optional)
%                   Default: 5
%
%   Notes
%   -----
% 
%   $SPK

[img,hsize] = ParseInputs(varargin{:});

h = fspecial('average',hsize);
J = imfilter(img,h);

filter_name = ['Average (',num2str(hsize),')'];

%%
clearvars -except J filter_name

%--------------------------------------------------------------------------
function [img,hsize] = ParseInputs(varargin)

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
hsize = 5;

% Parse Input Arguments
if nargin ~= 1
    hsize = varargin{2};
end

%%
clearvars -except img hsize
