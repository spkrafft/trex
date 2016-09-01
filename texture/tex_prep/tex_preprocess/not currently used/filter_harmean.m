function [J,filter_name] = filter_harmean(varargin)
%FILTER_HARMEAN Implements a harmonic mean filter
%   [IMG,FILTER_NAME] = FILTER_HARMEAN(IMG,SIZ)
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

J = siz*siz./imfilter(1./(img+eps),ones(siz,siz),'replicate');

filter_name = ['Harmonic Mean (',num2str(siz),')'];

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
