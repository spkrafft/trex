function [J,preprocess_name] = preprocess_filter_log_hsize6_sigma1_5(img)
%PREPROCESS_FILTER_LOG_HSIZE6_SIGMA1_5 
%   [IMG,preprocess_NAME] = PREPROCESS_FILTER_LOG_HSIZE6_SIGMA1_5(IMG)
%
%   Parameters include:
%  
%   'img'           Self explanatory
%
%   Notes
%   -----
% 
%   $SPK

[img] = ParseInputs(img);

hsize = 6;
sigma = 1.5;

h = fspecial('log',hsize,sigma);
J = imfilter(img,h);

preprocess_name = ['LoG Filter (',num2str(hsize),'/',num2str(sigma),')'];

%%
clearvars -except J preprocess_name

%--------------------------------------------------------------------------
function [img] = ParseInputs(varargin)

if verLessThan('matlab', '7.13')
    iptchecknargin(1,1,nargin,mfilename);
else
    narginchk(1,1);
end

% Check img
img = varargin{1};
validateattributes(img,{'numeric'},{'real','nonsparse'},mfilename,'img',1);
if ndims(img) > 3
  error(message('images:preprocess:invalidSizeForIMG'))
end

%%
clearvars -except img
