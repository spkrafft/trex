function [J,filter_name] = filter_min(varargin)
%FILTER_MIN Implements a min filter
%   [IMG,FILTER_NAME] = FILTER_MIN(IMG,SIZ)
%
%   Parameters include:
%  
%   'img'           Self explanatory
%
%   'siz'           (Optional)
%                   Default: 5
%
%   Notes
%   -----
%   From Gonzalez and Woods
%
%   $SPK

[img,siz] = ParseInputs(varargin{:});

J = imerode(img,ones(siz,siz));

filter_name = ['Min (',num2str(siz),')'];

%%
clearvars -except J filter_name

%--------------------------------------------------------------------------
function [img,siz] = ParseInputs(varargin)

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
siz = 5;

% Parse Input Arguments
if nargin ~= 1
    siz = varargin{2};
end

%%
clearvars -except img siz
