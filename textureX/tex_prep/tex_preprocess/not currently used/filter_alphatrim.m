function [J,filter_name] = filter_alphatrim(varargin)
%FILTER_ALPHATRIM Implements an alpha-trimed mean filter
%   [IMG,FILTER_NAME] = FILTER_ALPHATRIM(IMG,SIZ,D)
%
%   Parameters include:
%  
%   'img'           Self explanatory
%
%   'siz'           (Optional)
%                   Default: 5
%
%   'd'             (Optional)
%                   Default: 15
%
%   Notes
%   -----
%   From Gonzalez and Woods
% 
%   $SPK

[img,siz,d] = ParseInputs(varargin{:});

J = imfilter(img,ones(siz,siz),'symmetric');
for k = 1:d/2
    J = J-ordfilt2(img,k,ones(siz,siz),'symmetric');
end
for k = (siz*siz-(d/2)+1):siz*siz
    J = J-ordfilt2(img,k,ones(siz,siz),'symmetric');
end
J = J/(siz*siz-d);

filter_name = ['Alpha Trimed Mean (',num2str(siz),'/',num2str(d),')'];

%%
clearvars -except J filter_name

%--------------------------------------------------------------------------
function [img,siz,d] = ParseInputs(varargin)

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
d = 2;

% Parse Input Arguments
if nargin ~= 1
    siz = varargin{2};
    d = varargin{3};
    if (d<=0) || (d/2~=round(d/2))
        error('d must be a positive, even integer')
    end
end

%%
clearvars -except img siz d
