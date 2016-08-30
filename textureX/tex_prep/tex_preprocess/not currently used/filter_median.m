function [J,filter_name] = filter_median(varargin)
%FILTER_MEDIAN
%   [IMG,FILTER_NAME] = FILTER_MEDIAN(IMG,HSIZE)
%
%   Parameters include:
%  
%   'img'           Self explanatory
%
%   'hsize'         (Optional)
%                   Default: 3
%
%   Notes
%   -----
% 
%   $SPK

[img,hsize] = ParseInputs(varargin{:});

parfor i = 1:size(img,3)
    J(:,:,i) = medfilt2(img(:,:,i),[hsize,hsize]);
end

filter_name = ['Median (',num2str(hsize),')'];

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
hsize = 3;

% Parse Input Arguments
if nargin ~= 1
    hsize = varargin{2};
end

%%
clearvars -except img hsize
