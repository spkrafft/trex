function [J,preprocess_name] = preprocess_threshold(varargin)
%PREPROCESS_THRESHOLD
%   [IMG,PREPROCESS_NAME] = PREPROCESS_THRESHOLD(IMG,THRESHOLD)
%
%   Parameters include:
%  
%   'img'           Self explanatory
%
%   'threshold' 	(Optional)
%                   Default: 1000
%
%   Notes
%   -----
% 
%   $SPK

[img,threshold] = ParseInputs(varargin{:});

J = img;
J(J>threshold) = nan;

preprocess_name = ['Threshold (',num2str(threshold),')'];

%%
clearvars -except J preprocess_name

%--------------------------------------------------------------------------
function [img,threshold] = ParseInputs(varargin)

if verLessThan('matlab', '7.13')
    iptchecknargin(1,2,nargin,mfilename);
else
    narginchk(1,2);
end

% Check img
img = varargin{1};
validateattributes(img,{'numeric'},{'real','nonsparse'},mfilename,'img',1);
if ndims(img) > 3
  error(message('images:preprocess:invalidSizeForIMG'))
end

% Assign Defaults
threshold = 1000;

% Parse Input Arguments
if nargin ~= 1
    threshold = varargin{2};
end

%%
clearvars -except img threshold
