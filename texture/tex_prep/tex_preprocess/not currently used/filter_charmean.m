function [J,filter_name] = filter_charmean(varargin)
%FILTER_CHARMEAN Implements a contraharmonic mean filter
%   [IMG,FILTER_NAME] = FILTER_CHARMEAN(IMG,SIZ,Q)
%
%   Parameters include:
%  
%   'img'           Self explanatory
%
%   'siz'           (Optional)
%                   Default: 5
%
%   'q'             (Optional)
%                   Default: 0.5
%
%   Notes
%   -----
%   From Gonzalez and Woods
% 
%   $SPK

[img,siz,q] = ParseInputs(varargin{:});

J = imfilter(img.^(q+1),ones(siz,siz),'replicate');
J = J./(imfilter(img.^q,ones(siz,siz),'replicate')+eps);

filter_name = ['Contraharmonic Mean (',num2str(siz),'/',num2str(q),')'];

%%
clearvars -except J filter_name

%--------------------------------------------------------------------------
function [img,siz,q] = ParseInputs(varargin)

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
siz = 5;
q = 0.5;

% Parse Input Arguments
if nargin ~= 1
    siz = varargin{2};
    q = varargin{3};
end

%%
clearvars -except img siz q
